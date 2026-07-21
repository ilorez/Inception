#!/bin/bash

# Download WordPress
wget -q https://wordpress.org/latest.tar.gz -P /tmp
tar -xzf /tmp/latest.tar.gz -C /var/www/
mkdir -p /var/www/html
mv /var/www/wordpress/* /var/www/html/

# Download WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# Create wp-config.php
wp config create \
	--dbname=$WP_DB_NAME \
	--dbuser=$WP_DB_USER \
	--dbpass=$(cat $WP_DB_PASSWORD_FILE) \
	--dbhost=$WP_DB_HOST \
	--path=/var/www/html \
	--allow-root

# Install WordPress
wp core install \
	--url=$DOMAIN_NAME \
	--title="Inception" \
	--admin_user=$WP_ADMIN_USER \
	--admin_password=$(cat $WP_ADMIN_PASSWORD_FILE) \
	--admin_email=$WP_ADMIN_EMAIL \
	--path=/var/www/html \
	--allow-root

# Start PHP-FPM in foreground
php-fpm7.4 -F