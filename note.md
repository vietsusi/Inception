# YML file:
1. Services
mariadb: Database service
- Uses port 3306 internally (standard MySQL port)
- Not exposed to host (only accessible inside the network)

wordpress: PHP application service
- Uses port 9000 internally (PHP-FPM default)
- Not exposed to host

nginx: Web server
- Exposes port 443 to host (HTTPS)
- Acts as the entry point for users

2. Volumes
- mariadb-test: Persists database data
- wp-test: Persists WordPress files (shared between wordpress and nginx)

3. Network
- all containers share docker-network bridge

# Connection Flow:
User Browser
    ↓ (HTTPS:443)
    ↓
Nginx Container (port 443)
    ↓ (FastCGI:9000)
    ↓
WordPress Container (port 9000 - PHP-FPM)
    ↓ (MySQL:3306)
    ↓
MariaDB Container (port 3306)

# How to change port:
1. Change Nginx Port: 443 -> 8443
 - docker-compose.yml: 443:443 to 8443:443
 - nginx-entrypoint.sh: 443 -> 8443

2. Change WordPres PHP-FPM Port: 9000 -> 9001
 - wordpress-entrypoint.sh: sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' 
        -> sed -i 's/listen = 127.0.0.1:9000/listen = 9001/g'
 - nginx-etrypoint.sh: fastcgi_pass wordpress:9000; -> fastcgi_pass wordpress:9001;

3. Change MariaDB Port: 3306 -> 3307
 - mariadb-entrypoint.sh:
    [mysqld]
    bind-address=0.0.0.0
    skip-networking=0
    -> [mysqld]
        port=3307 #(add here)
        bind-address=0.0.0.0
        skip-networking=0

 - wordpress-entrypoint.sh:
    wp config create --allow-root \
            --dbhost=mariadb \
            --dbuser="$MYSQL_USER" \
            --dbpass="$MYSQL_PASSWORD" \
            --dbname="$MYSQL_DATABASE"
    -> change to 
    wp config create --allow-root \
            --dbhost=mariadb:3307 \
            --dbuser="$MYSQL_USER" \
            --dbpass="$MYSQL_PASSWORD" \
            --dbname="$MYSQL_DATABASE"
     # Wait for MariaDB to be ready
    mariadb-admin ping --protocol=tcp --host=mariadb -u "$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null 2>/dev/null
    -> change to
    mariadb-admin ping --protocol=tcp --host=mariadb --port=3307 -u "$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null 2>/dev/null
