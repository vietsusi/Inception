#!/bin/bash
set -e

echo "=== WordPress Entrypoint Started ==="

# Ensure directory exists
mkdir -p /var/www/html
cd /var/www/html

# Configure PHP-FPM on the first run
if [ ! -e /etc/.firstrun ]; then
    echo "Configuring PHP-FPM..."
    sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /etc/php82/php-fpm.d/www.conf
    touch /etc/.firstrun
fi

# CHECK: If .firstmount exists but WordPress files are missing 
if [ -f .firstmount ] && [ ! -f wp-config.php ]; then
    echo " WARNING: .firstmount exists but WordPress files are missing!"
    echo "Removing .firstmount and reinstalling..."
    rm -f .firstmount
fi

# On the first volume mount, download and configure WordPress
if [ ! -e .firstmount ]; then
    echo "Installing WordPress..."
    
    # Wait for MariaDB to be ready
    echo "Waiting for MariaDB..."
    for i in {1..30}; do
        if mariadb-admin ping --protocol=tcp --host=mariadb \
            -u "$MYSQL_USER" --password="$MYSQL_PASSWORD" \
            >/dev/null 2>&1; then
            echo "MariaDB is ready!"
            break
        fi
        if [ $i -eq 30 ]; then
            echo "ERROR: MariaDB not ready after 30 seconds"
            exit 1
        fi
        echo "Attempt $i/30..."
        sleep 1
    done

    # Download WordPress core
    echo "Downloading WordPress..."
    if ! wp core download --allow-root; then
        echo "ERROR: Failed to download WordPress"
        exit 1
    fi

    # Create wp-config.php
    echo "Creating wp-config.php..."
    wp config create --allow-root \
        --dbhost=mariadb \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbname="$MYSQL_DATABASE"

    # Configure WordPress options
    wp config set WP_CACHE true --raw --allow-root
    wp config set FS_METHOD direct --allow-root

    # Check if WordPress is already installed in database
    if wp core is-installed --allow-root 2>/dev/null; then
        echo "WordPress database already exists. Skipping install."
    else
        echo "Installing WordPress..."
        wp core install --allow-root \
            --skip-email \
            --url="$DOMAIN_NAME" \
            --title="$WORDPRESS_TITLE" \
            --admin_user="$WORDPRESS_ADMIN_USER" \
            --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
            --admin_email="$WORDPRESS_ADMIN_EMAIL"

        # Create a regular user if it doesn't already exist
        if ! wp user get "$WORDPRESS_USER" --allow-root > /dev/null 2>&1; then
            echo "Creating regular user..."
            wp user create "$WORDPRESS_USER" "$WORDPRESS_EMAIL" \
                --role=author \
                --user_pass="$WORDPRESS_PASSWORD" \
                --allow-root
        fi
    fi

    chmod o+w -R /var/www/html/wp-content
    touch .firstmount
    echo "WordPress installation completed successfully!"
else
    echo "WordPress is already installed."
fi

# Show debug info
echo "=== Debug Info ==="
echo "Files in /var/www/html:"
ls -la /var/www/html/ | head -20
echo "wp-config.php exists: $(test -f wp-config.php && echo '✅ Yes' || echo '❌ No')"
echo "==================="

# Start PHP-FPM
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm82 -F