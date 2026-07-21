FROM debian:bullseye

RUN apt-get update && apt-get install mariadb-server tini -y 

WORKDIR /init_script

COPY ./tools/init.sh ./init.sh

RUN chmod +x ./init.sh

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["./init.sh"]
