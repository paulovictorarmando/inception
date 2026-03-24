FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        php \
        php-fpm \
        php-mysql \
        mariadb-client && \
    update-ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -O /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# Config PHP-FPM
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Criar pasta do WordPress
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Script de setup
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["sh", "/usr/local/bin/setup.sh"]