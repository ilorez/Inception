#!/bin/bash
sed -i "s/^port .*/port ${REDIS_PORT}/" /etc/redis/redis.conf
exec redis-server /etc/redis/redis.conf