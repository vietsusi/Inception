FROM alpine

# Install Nginx Openssl Bash
RUN apk update && \
    apk add nginx openssl bash

# Copy entrypoint script and set execution for it. Make directory html and ssl
COPY tools/nginx-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/nginx-entrypoint.sh && \
    mkdir -p /etc/nginx/ssl /var/www/html

ENTRYPOINT [ "nginx-entrypoint.sh" ]