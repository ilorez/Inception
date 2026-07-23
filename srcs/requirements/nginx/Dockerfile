FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl && rm -rf /var/lib/apt/lists/*

# FOR DEBUG
# RUN apt-get update && apt-get install -y procps curl iputils-ping && rm -rf /var/lib/apt/lists/*

COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf

# remove default conf so user can't access using http
RUN rm -rf /etc/nginx/sites-enabled/default

COPY ./tools/init.sh /init.sh

RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]


