FROM alpine:3.22.4

RUN apk add --no-cache openssl curl ca-certificates gettext

RUN printf "%s%s%s%s\n" \
  "@nginx " \
  "https://nginx.org/packages/alpine/v" \
  `egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release` \
  "/main" \
  | tee -a /etc/apk/repositories

RUN curl -o /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub
RUN openssl rsa -pubin -in /tmp/nginx_signing.rsa.pub -text -noout
RUN mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/
RUN apk add nginx@nginx

COPY conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 443

ENTRYPOINT ["entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
