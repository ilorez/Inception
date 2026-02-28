#!/bin/bash


# Download WordPress only if not already present
if [ ! -f /var/www/html/wp-config.php ]; then
  # Download WordPress
  wget -q https://wordpress.org/latest.tar.gz -P /tmp
  mkdir -p /var/www/html
  tar -xzf /tmp/latest.tar.gz -C /var/www/
  mv /var/www/wordpress/* /var/www/html/
  rm -r /var/www/wordpress

  until mysqladmin ping \
    -h mariadb -u znajdaou -p123 --silent 2>/dev/null; do
      echo "Waiting for MariaDB..."
      sleep 1
  done

  # Create wp-config.php
  wp config create \
  	--dbname=wordpress \
  	--dbuser=znajdaou \
  	--dbpass=123 \
  	--dbhost=mariadb \
  	--path=/var/www/html \
  	--allow-root
  
  # Install WordPress
  wp core install \
  	--url=localhost \
  	--title="Inception" \
  	--admin_user=znajdaou \
  	--admin_password=123 \
  	--admin_email=zobirnajdaoui@gmail.com \
  	--path=/var/www/html \
  	--allow-root
fi
  
# Start PHP-FPM in foreground
mkdir -p /run/php

# exec php7.4-fpm -F
exec $(ls /usr/sbin/php-fpm*) -F
