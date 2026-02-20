# Imagem base estável (evite latest → builds imprevisíveis)
FROM debian:bullseye

# Instala apenas o necessário para rodar o banco
# --no-install-recommends evita lixo extra
RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Substitui config padrão do MySQL/MariaDB
# Precisamos controlar bind-address manualmente
COPY conf/my.cnf /etc/mysql/my.cnf

# Script responsável por inicializar o banco automaticamente
# Containers não podem depender de configuração manual
COPY tools/setup.sh /setup.sh

# Permissão obrigatória para executar
RUN chmod +x /setup.sh

# Documentação apenas (não publica porta sozinho)
EXPOSE 3306

# Container inicia rodando nosso script
# Ele cria DB, usuário e depois inicia o servidor
ENTRYPOINT ["/setup.sh"]