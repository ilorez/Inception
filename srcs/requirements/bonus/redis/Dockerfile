FROM debian:bullseye

RUN apt-get update && apt-get install -y redis-server && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /etc/redis

COPY ./conf/redis.conf .

CMD ["redis-server", "/etc/redis/redis.conf"]