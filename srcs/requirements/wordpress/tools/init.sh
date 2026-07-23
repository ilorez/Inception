#!/bin/bash

# Wait for MariaDB to be ready before proceeding.
# /dev/tcp/host/port is a bash built-in — not a real file on disk.
# When bash sees it as a redirect target, it opens a TCP connection instead.
# If the connection succeeds (port open) → exit 0 → loop ends.
# If refused (MariaDB not ready yet) → exit 1 → sleep and retry.
# We use "bash -c" to ensure bash handles it, even if the parent shell is sh.
until bash -c "echo > /dev/tcp/$WP_DB_HOST/3306" 2>/dev/null; do
    echo "waiting for mariadb..."
    sleep 2
done

# Create wp-config.php only if missing
if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbhost=$WP_DB_HOST \
        --path=/var/www/html \
        --allow-root \
        --prompt=dbpass < $MYSQL_PASSWORD_FILE
fi

# Install only if not already installed
if ! wp core is-installed --path=/var/www/html --allow-root; then
    wp core install \
        --url=$DOMAIN_NAME \
        --title="Inception" \
        --admin_user=$WP_ADMIN_USER \
        --admin_email=$WP_ADMIN_EMAIL \
        --path=/var/www/html \
        --allow-root \
        --prompt=admin_password < $WP_ADMIN_PASSWORD_FILE
fi

# second user
if ! wp user get $WP_DB_USER --path=/var/www/html --allow-root > /dev/null 2>&1; then
    wp user create \
        $WP_DB_USER \
        $WP_DB_EMAIL \
        --role=author \
        --user_pass=$(cat $WP_DB_PASSWORD_FILE) \
        --path=/var/www/html \
        --allow-root
fi

exec php-fpm8.4 -F