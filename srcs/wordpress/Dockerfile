FROM debian:bookworm
RUN apt-get update && \
    apt-get install -y php-fpm php-mysql wget unzip && \
    rm -rf /var/lib/apt/lists/*

COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh


RUN mkdir -p /var/www/html
WORKDIR /var/www/html

RUN wget https://wordpress.org/latest.zip && \
    unzip latest.zip && \
    mv wordpress/* . && rm -rf wordpress latest.zip

#COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000
ENTRYPOINT ["/setup.sh"]


#Cria o diretório /var/www/html.
#É o diretório padrão onde o Nginx ou PHP-FPM vai servir os arquivos da web.
#-p garante que todos os diretórios intermediários sejam criados se não existirem.

#php-fpm	PHP FastCGI Process Manager. É o PHP que vai processar scripts do WordPress, separado do Nginx.
#php-mysql	Extensão PHP para conectar com MySQL/MariaDB. WordPress precisa disso para funcionar.
#wget	Ferramenta de download de arquivos via terminal. Útil para baixar WordPress ou outros assets.
#unzip	Ferramenta para descompactar arquivos .zip. Necessário porque o WordPress oficial vem em ZIP


#echo "wp_password_here" > ./srcs/secrets/db_user_password.txt
#echo "root_password_here" > ./srcs/secrets/db_root_password.txt
#echo "admin_password_here" > ./srcs/secrets/wp_admin_password.txt
#echo "user_password_here" > ./srcs/secrets/wp_user_password.txt

