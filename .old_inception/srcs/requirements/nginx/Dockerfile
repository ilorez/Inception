FROM debian:bullseye

RUN apt-get update && apt-get install -y \
  tini \
  nginx \
  openssl \
  && rm -rf /var/lib/apt/lists/*

COPY ./conf/nginx.conf /etc/nginx/sites-available/default
COPY ./tools/init.sh /init.sh

RUN chmod +x /init.sh
EXPOSE 443

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/init.sh"]

