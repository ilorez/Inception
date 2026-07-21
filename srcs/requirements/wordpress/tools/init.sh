# Create wp-config.php only if missing
if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --dbname=$WP_DB_NAME \
        --dbuser=$WP_DB_USER \
        --dbpass=$(cat $WP_DB_PASSWORD_FILE) \
        --dbhost=$WP_DB_HOST \
        --path=/var/www/html \
        --allow-root
fi

# Install only if not already installed
if ! wp core is-installed --path=/var/www/html --allow-root; then
    wp core install \
        --url=$DOMAIN_NAME \
        --title="Inception" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$(cat $WP_ADMIN_PASSWORD_FILE) \
        --admin_email=$WP_ADMIN_EMAIL \
        --path=/var/www/html \
        --allow-root
fi

exec php-fpm8.4 -F