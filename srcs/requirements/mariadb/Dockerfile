FROM  alpine:3.20.6

#Install MariaDB and its client
RUN apk update && apk add --no-cache mariadb mariadb-client

#Copy configuration and tools
COPY ./conf/mariadb_config /etc/my.cnf.d/mariadb_config
COPY ./tools/mariadb-script.sh /usr/local/bin/mariadb-script.sh

#Change permissions to 644 for system to read it
RUN chmod 644 /etc/my.cnf.d/mariadb_config
RUN chmod +x /usr/local/bin/mariadb-script.sh

#Open database port -3306
EXPOSE 3306

#Start the database
ENTRYPOINT ["mariadb-script.sh"]
