FROM debian:bullseye

RUN apt-get update && apt-get install -y redis-server && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY ./tools/init.sh /init.sh
RUN chmod +x /init.sh

COPY ./conf/redis.conf /etc/redis/redis.conf

ENTRYPOINT ["./init.sh"]