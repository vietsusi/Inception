# Create a new entrypoint that starts PHP-FPM regardless of database
docker exec wordpress sh -c 'cat > /entrypoint.sh << "EOF"
#!/bin/sh
set -e

# Copy WordPress files if needed
if [ ! -f /var/www/html/wp-config.php ] && [ ! -f /var/www/html/index.php ]; then
    echo "Populating /var/www/html from /usr/src/wordpress..."
    cp -r /usr/src/wordpress/* /var/www/html/
fi

# Generate wp-config.php with placeholder values if it doesn't exist
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Generating placeholder wp-config.php..."
    cat > /var/www/html/wp-config.php <<CONFIG
<?php
define( "DB_NAME", "wordpress" );
define( "DB_USER", "wp_user" );
define( "DB_PASSWORD", "password" );
define( "DB_HOST", "mariadb:3306" );
define( "DB_CHARSET", "utf8" );
define( "DB_COLLATE", "" );
define( "WP_DEBUG", true );
\$table_prefix = "wp_";
if ( ! defined( "ABSPATH" ) ) {
    define( "ABSPATH", __DIR__ . "/" );
}
require_once ABSPATH . "wp-settings.php";
CONFIG
fi

chown -R nobody:nobody /var/www/html

# Always start PHP-FPM (don't wait for database)
echo "Starting PHP-FPM..."
exec php-fpm83 -F
EOF'

docker exec wordpress chmod +x /entrypoint.sh
docker restart wordpress

sleep 3

# Test
docker exec wordpress ps aux | grep php-fpm
wget --no-check-certificate -q -O - https://localhost/test.php 2>&1 | head -20