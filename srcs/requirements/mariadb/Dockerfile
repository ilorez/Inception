FROM debian:bullseye


RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/* && rm -rf /var/lib/mysql/*


# This changes MariaDB's config to listen on all interfaces, not just localhost.
#RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' \
#    /etc/mysql/mariadb.conf.d/50-server.cnf

WORKDIR /init_script

COPY ./tools/init.sh ./init.sh

RUN chmod +x ./init.sh

ENTRYPOINT ["./init.sh"]