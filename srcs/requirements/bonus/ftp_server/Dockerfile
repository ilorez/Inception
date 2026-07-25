FROM debian:bullseye

RUN apt-get update && apt-get install -y vsftpd tini && rm -rf /var/lib/apt/lists/*

COPY ./conf/vsftpd.conf /etc/vsftpd.conf

COPY ./tools/init.sh /init.sh
RUN chmod +x /init.sh

# EXPOSE 21 30000-30009

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/init.sh"]