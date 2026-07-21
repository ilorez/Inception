FROM debian:bullseye

RUN apt-get update && apt-get install -y curl ca-certificates lsb-release \
    && curl -sSL https://packages.sury.org/php/apt.gpg -o /usr/share/keyrings/sury-php.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" \
       > /etc/apt/sources.list.d/sury-php.list \
    && apt-get update && apt-get install -y \
    php8.4-fpm \
    php8.4-mysql \
    php8.4-curl \
    php8.4-xml \
    php8.4-gd \
    php8.4-imagick \
    php8.4-intl \
    php8.4-mbstring \
    php8.4-zip \
    php8.4-exif \
    imagemagick \
    && ln -s /usr/bin/php8.4 /usr/bin/php \
    && rm -rf /var/lib/apt/lists/*

# delete inded files (apt-get update - a catalog of all available packages, their versions) from RUN snapshots that reduce layer size by 50 to 100 MB



# Download WordPress
# wget -q https://wordpress.org/latest.tar.gz -P /tmp
# tar -xzf /tmp/latest.tar.gz -C /var/www/
# mkdir -p /var/www/html
# mv /var/www/wordpress/* /var/www/html/

RUN mkdir -p /var/www/html && \
    curl -o /tmp/latest.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf /tmp/latest.tar.gz -C /var/www/ && \
    mv /var/www/wordpress/* /var/www/html/ && \
    rm -rf /tmp/latest.tar.gz


# Download WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
  chmod +x wp-cli.phar && \
  mv wp-cli.phar /usr/local/bin/wp



# Configure PHP-FPM to listen on port 9000 instead of the default Unix socket
RUN sed -i 's|listen = /run/php/php8.4-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/8.4/fpm/pool.d/www.conf

COPY tools/init.sh /init.sh
RUN chmod +x /init.sh

# in case of using docker-compose, and network wp_network bridge internal, the port 9000 is not needed to be exposed, but if you want to run the container directly, you need to expose it to access it from outside the container
# EXPOSE 9000

ENTRYPOINT ["/init.sh"]
