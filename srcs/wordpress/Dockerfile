FROM debian:bookworm
RUN apt-get update && \
    apt-get install -y php-fpm php-mysql wget unzip default-mysql-client curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

RUN mkdir -p /var/www/html
WORKDIR /var/www/html

RUN wget https://wordpress.org/latest.zip && \
    unzip latest.zip && \
    mv wordpress/* . && rm -rf wordpress latest.zip

RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000
ENTRYPOINT ["/setup.sh"]

