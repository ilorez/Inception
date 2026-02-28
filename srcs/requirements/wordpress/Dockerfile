FROM debian:bullseye
RUN apt-get update && apt-get install -y \
  tini \
  php-fpm \
  php-mysql \
  wget \
  curl \
  mariadb-client \
  && rm -rf /var/lib/apt/lists/*


# Download WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
  chmod +x wp-cli.phar && \
  mv wp-cli.phar /usr/local/bin/wp

# delete inded files (apt-get update - a catalog of all available packages, their versions) from RUN snapshots that reduce layer size by 50 to 100 MB

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh
EXPOSE 9000
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/init.sh"]
