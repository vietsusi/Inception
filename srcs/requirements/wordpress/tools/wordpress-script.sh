#!/bin/sh

echo "==> Setting up WordPress..."
echo "memory_limit = 512M" >> /etc/php83/php.ini

cd /var/www/html

echo "==> Downloading WordPress client (WP-CLI) and renaming wp-cli.phar to wp..."
wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp || { echo "Failed to download wp-cli.phar"; exit 1; }

chmod +x /usr/local/bin/wp

echo "==> Checking if MariaDB is running before proceeding with WordPress setup..."
mariadb-admin ping --protocol=tcp --host=mariadb -u $WORDPRESS_DATABASE_USER --password=$WORDPRESS_DATABASE_USER_PASSWORD --wait=300

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "==> Downloading, Installing, Configuring WordPress files (core essentials)..."
    wp core download --allow-root

    wp config create \
        --dbname=$WORDPRESS_DATABASE_NAME \
        --dbuser=$WORDPRESS_DATABASE_USER \
        --dbpass=$WORDPRESS_DATABASE_USER_PASSWORD \
        --dbhost=mariadb \
        --force

    wp core install --url="$DOMAIN_NAME" --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --allow-root \
        --skip-email \
        --path=/var/www/html

    echo "==> Creating a WordPress user..."
    wp user create \
        --allow-root \
        $WORDPRESS_USER $WORDPRESS_USER_EMAIL \
        --user_pass=$WORDPRESS_USER_PASSWORD
else
    echo "==> WordPress is already downloaded, installed, and configured."
fi

chown -R www-data:www-data /var/www/html

chmod -R 755 /var/www/html/

echo "==> Running PHP-FPM in the foreground (to prevent the container from stopping)..."
php-fpm83 -F

