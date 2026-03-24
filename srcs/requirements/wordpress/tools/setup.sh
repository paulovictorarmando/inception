#!/bin/sh

export PATH=$PATH:/usr/local/bin

SQL_PASSWORD=$(cat /run/secrets/db_user_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Esperar MariaDB
until mysqladmin ping -h mariadb -u"$SQL_USER" -p"$SQL_PASSWORD" --silent; do
    sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root --path=/var/www/html

    wp config create --allow-root \
        --dbname=$SQL_DATABASE \
        --dbuser=$SQL_USER \
        --dbpass=$SQL_PASSWORD \
        --dbhost=mariadb:3306 \
        --path=/var/www/html

    wp core install --allow-root \
        --url=$DOMAIN_NAME \
        --title="Inception 42" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --path=/var/www/html

    wp user create --allow-root \
        $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASSWORD \
        --path=/var/www/html

    chown -R www-data:www-data /var/www/html
fi

mkdir -p /run/php

exec php-fpm8.2 -F