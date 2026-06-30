FROM alpine

RUN apk update && \
    apk add nginx openssl bash

COPY tools/nginx-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/nginx-entrypoint.sh && \
    mkdir -p /etc/nginx/ssl /var/www/html

ENTRYPOINT [ "nginx-entrypoint.sh" ]