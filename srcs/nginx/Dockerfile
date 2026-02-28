FROM debian:bookworm

# Instala Nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*

# Copia a configuração
COPY conf/default.conf /etc/nginx/sites-available/default

# Expondo portas
EXPOSE 80 443

# Rodar Nginx no foreground
CMD ["nginx", "-g", "daemon off;"]