#!/bin/bash

set -e

# Debug: Show environment variables
echo "=== Environment Variables ==="
echo "MYSQL_DATABASE: ${MYSQL_DATABASE}"
echo "MYSQL_USER: ${MYSQL_USER}"
echo "MYSQL_PASSWORD: ${MYSQL_PASSWORD}"
echo "MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}"
echo "=============================="

# Check first run: listen on all interfaces: 0.0.0.0
if [ ! -e /etc/.firstrun ]; then
    cat << EOF >> /etc/my.cnf.d/mariadb-server.cnf
[mysqld]
bind-address=0.0.0.0
skip-networking=0
EOF
    touch /etc/.firstrun
fi

# Check first mount
if [ ! -e /var/lib/mysql/.firstmount ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --datadir=/var/lib/mysql --skip-test-db --user=mysql --group=mysql \
            --auth-root-authentication-method=socket
    
    echo "Starting MariaDB temporarily..."
    mysqld_safe &
    mysqld_pid=$!

    echo "Waiting for MariaDB to start..."
    mysqladmin ping -u root --silent --wait >/dev/null 2>/dev/null
    
    echo "Creating database: ${MYSQL_DATABASE}"
    
    # Show the SQL that will be executed
    echo "=== SQL to execute ==="
    cat << EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
    echo "======================"
    
    # Execute SQL
    cat << EOF | mysql --protocol=socket -u root
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

    echo "Shutting down temporary MariaDB..."
    mysqladmin shutdown
    touch /var/lib/mysql/.firstmount
    echo "Initialization complete!"
fi

echo "Starting MariaDB in foreground..."
# Start MariaDB in foreground
exec mysqld_safe