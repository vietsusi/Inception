FROM alpine:3.22.4

RUN apk add --no-cache \
    wget tar \
    php php-fpm \
    php-mysqli php-curl php-mbstring php-xml php-zip php-openssl \
    php-gd php-session php-intl php-fileinfo php-exif php-ctype \
    php-dom php-iconv php-simplexml php-xmlreader php-xmlwriter \
    php-sodium php-phar \
    mariadb-client

RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

RUN mkdir -p /usr/src/wordpress /var/www/html

RUN cd /tmp && \
    wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    cp -r wordpress/* /usr/src/wordpress/ && \
    rm -rf latest.tar.gz wordpress && \
    chown -R nobody:nobody /usr/src/wordpress /var/www/html

RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php83/php-fpm.d/www.conf

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm83", "-F"]