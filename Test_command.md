
# Build
docker compose -f ./srcs/docker-compose.yml up -d --build

# Remove
docker compose -f ./srcs/docker-compose.yml down

# Clean
docker system prune -a -f --volumes

# Check status
docker ps -a

# check log
docker logs mariadb
docker logs wordpress
docker logs nginx


# 1. Test MariaDB Connection
# Check if MariaDB is running and accessible
docker exec -it mariadb mysqladmin -u root -p1234 status

# Check databases
docker exec -it mariadb mysql -u root -p1234 -e "SHOW DATABASES;"

# Check WordPress database tables
docker exec -it mariadb mysql -u root -p1234 -e "USE mariadb; SHOW TABLES;"
# 2. Test WordPress and MariaDB connection
# WordPress database check
docker exec -it wordpress wp --path=/var/www/html db check --allow-root

# Show WordPress tables
docker exec -it wordpress wp --path=/var/www/html db tables --allow-root

# Check WordPress users
docker exec -it wordpress wp --path=/var/www/html user list --allow-root

# 3. Test Nginx and WordPress connection
# Test HTTPS - should return WordPress homepage
docker exec -it nginx wget --no-check-certificate -O- https://localhost 2>/dev/null | head -30

# Check if nginx can see WordPress files
docker exec -it nginx ls -la /var/www/html/ | head -10

# Check nginx configuration
docker exec -it nginx nginx -t

# 4. Test PHP -FPM Processing
# Create a PHP test file in WordPress container
docker exec -it wordpress bash -c "echo '<?php phpinfo(); ?>' > /var/www/html/test.php"

# Test PHP through nginx
docker exec -it nginx wget --no-check-certificate -O- https://localhost/test.php 2>/dev/null | grep -i "PHP Version" | head -1

# Clean up
docker exec -it wordpress rm /var/www/html/test.php

# 5. Test End to End Connection
# Get WordPress site URL
docker exec -it wordpress wp --path=/var/www/html option get siteurl --allow-root

# Create a test post
docker exec -it wordpress wp --path=/var/www/html post create \
  --post_title="Connection Test Post" \
  --post_content="Testing if WordPress, MariaDB, and Nginx are all connected" \
  --post_status=publish \
  --allow-root

# List recent posts
docker exec -it wordpress wp --path=/var/www/html post list --posts_per_page=3 --allow-root

# View the post through nginx
docker exec -it nginx wget --no-check-certificate -O- https://localhost/?p=1 2>/dev/null | grep -i "Connection Test Post"

# Test internal connectivity
docker exec -it nginx ping wordpress
docker exec -it wordpress nc -zv mariadb 3306