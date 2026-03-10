FROM debian:bookworm

# Instala Nginx e OpenSSL
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Gera certificado autoassinado
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
        -subj "/CN=parmando.42.fr/O=Inception/C=FR" \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt

# Copia a configuração
COPY conf/default.conf /etc/nginx/sites-available/default

# Expondo portas
EXPOSE 80 443

# Rodar Nginx no foreground
CMD ["nginx", "-g", "daemon off;"]