#!/bin/bash

set -e

if [ ! -e /etc/.firstrun ]; then
    cat << EOF >> /etc/my.cnf.d/mariadb-server.cnf
[mysqld]
bind-address=0.0.0.0
skip-networking=0
EOF
    touch /etc/.firstrun
fi

if [ ! -e /var/lib/mysql/.firstmount ]; then
    mysql_install_db --datadir=/var/lib/mysql --skip-test-db --user=mysql --group=mysql \
            --auth-root-authentication-method=socket >/dev/null 2>/dev/null
    mysqld_safe &
    mysqld_pid=$!

    mysqladmin ping -u root --silent --wait >/dev/null 2>/dev/null
    cat << EOF | mysql --protocol=socket -u root -p=
CREATE DATABASE $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES on *.* to 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF

    mysqladmin shutdown
    touch /var/lib/mysql/.firstmount
fi

exec mysqld_safe