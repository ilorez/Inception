FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server tini

COPY tools/init.sh /init.sh

RUN chmod +x /init.sh

RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' \
    /etc/mysql/mariadb.conf.d/50-server.cnf
# This changes MariaDB's config to listen on all interfaces, not just localhost.
# adding the tini as PID 1 for handel signals and zombie process
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/init.sh"]

