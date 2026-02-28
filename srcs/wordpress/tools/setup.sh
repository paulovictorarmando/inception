#!/bin/bash
set -e

# ================================
#  Ler secrets
# ================================
DB_USER_PASSWORD=$(cat "$DB_USER_PASSWORD_FILE")
WORDPRESS_ADMIN_PASSWORD=$(cat "$WORDPRESS_ADMIN_PASSWORD_FILE")
WORDPRESS_USER_PASSWORD=$(cat "$WORDPRESS_USER_PASSWORD_FILE")

# ================================
# Validar variáveis obrigatórias
# ================================
: "${WORDPRESS_DB_HOST:?Variável WORDPRESS_DB_HOST não setada}"
: "${WORDPRESS_DB_NAME:?Variável WORDPRESS_DB_NAME não setada}"
: "${WORDPRESS_DB_USER:?Variável WORDPRESS_DB_USER não setada}"
: "${WORDPRESS_DB_PASSWORD:?Variável WORDPRESS_DB_PASSWORD não setada}"
: "${WP_ADMIN_USER:?Variável WP_ADMIN_USER não setada}"
: "${WP_ADMIN_EMAIL:?Variável WP_ADMIN_EMAIL não setada}"
: "${WP_USER:?Variável WP_USER não setada}"
: "${WP_USER_EMAIL:?Variável WP_USER_EMAIL não setada}"

# ================================
# Ajustar permissões da pasta
# ================================
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# ================================
# Esperar o MariaDB estar pronto
# ================================
echo "⏳ Aguardando MariaDB..."
until mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$DB_USER_PASSWORD" --silent; do
  sleep 2
done
echo "✅ MariaDB pronto!"

# ================================
# Criar wp-config.php se não existir
# ================================
if [ ! -f /var/www/html/wp-config.php ]; then
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

    sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" /var/www/html/wp-config.php
    sed -i "s/username_here/${WORDPRESS_DB_USER}/" /var/www/html/wp-config.php
    sed -i "s/password_here/${DB_USER_PASSWORD}/" /var/www/html/wp-config.php
    sed -i "s/localhost/${WORDPRESS_DB_HOST}/" /var/www/html/wp-config.php

    # Gerar salt keys
    curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/html/wp-config.php
fi

# ================================
# Instalar WP-CLI se não existir
# ================================
if ! command -v wp &> /dev/null; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# ================================
# Instalar WordPress Core se não estiver instalado
# ================================
wp core is-installed --allow-root || \
wp core install \
    --url="http://localhost" \
    --title="Inception WP" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --allow-root

# ================================
#  Criar usuários se não existirem
# ================================
wp user get "$WP_ADMIN_USER" --allow-root || \
    wp user create "$WP_ADMIN_USER" "$WP_ADMIN_EMAIL" --role=administrator --user_pass="$WORDPRESS_ADMIN_PASSWORD" --allow-root

wp user get "$WP_USER" --allow-root || \
    wp user create "$WP_USER" "$WP_USER_EMAIL" --role=editor --user_pass="$WORDPRESS_USER_PASSWORD" --allow-root

# ================================
#  Rodar PHP-FPM em foreground
# ================================
exec php-fpm8.2 -F