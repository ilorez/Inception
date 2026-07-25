FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php7.4-cli php7.4-mysqli \
    curl \
    tini \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/adminer
RUN curl -o index.php -L https://www.adminer.org/latest.php

# EXPOSE 8080
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["php7.4", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]