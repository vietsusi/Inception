FROM alpine

# Install MariaDB Server and Client
RUN apk update && \
    apk add mariadb mariadb-client bash

# Copy entrypoint script and set execution for it
COPY tools/mariadb-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

ENTRYPOINT [ "mariadb-entrypoint.sh" ]