#!/bin/bash

set -e

if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]; then
    echo ":cold_face: Erro grave: Variáveis de ambiente ou secrets não configurados corretamente."
    exit 1
fi
echo "Configurações carregadas com sucesso"

echo "Iniciando o MariaDB..."

chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing database..."
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
fi

echo "Executando MariaDB..."

#não tenta resolver nomes de host via DNS (mais rápido)
mysqld_safe --skip-name-resolve &
pid="$!"
#checa se banco está aceitando conexões
until mysqladmin ping &>/dev/null; do
    echo "Aguardando conexão com o banco de dados..."
    sleep 1
done

echo "O banco de dados está funcionando corretamente."

mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
EOSQL

mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

echo "===> Iniciando MariaDB... <==="
exec mysqld --bind-address=0.0.0.0 --user=mysql --datadir=/var/lib/mysql



    #environment:
    #  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    #  MYSQL_DATABASE: ${MYSQL_DATABASE}
    #  MYSQL_USER: ${MYSQL_USER}
    # MYSQL_PASSWORD: ${MYSQL_PASSWORD}


#               docker compose up
#imagens (se não existirem)
#volumes
#network
#containers
#inicia tudo
#               docker compose down
#para tudo
#remove containers, network, volumes (se quiser) 
#               docker compose build
#reconstrói as imagens (se o Dockerfile ou arquivos relacionados mudaram)
#               docker compose ps
#lista os containers em execução 
#               docker compose logs
#exibe os logs dos containers (útil para debug)
#               docker compose exec mariadb bash
#acessa o terminal do container mariadb (útil para debug e administração)
#               docker compose down -v
#para tudo e remove os volumes (cuidado, dados serão perdidos) 
#               docker compose down --rmi all
#para tudo e remove as imagens (útil para limpar espaço, mas cuidado com o tempo de reconstrução)
#               docker compose down --remove-orphans
#para tudo e remove containers órfãos (containers que não estão mais definidos no docker-compose
#               docker compose up --build
#reconstrói as imagens e inicia os containers (útil quando o Dockerfile ou arquivos relacionados mudaram)
#               docker compose restart
#reinicia os containers (útil para aplicar mudanças de configuração sem reconstruir as imagens)
#               docker compose stop
#para os containers sem removê-los (útil para manutenção temporária)
#               docker compose start
#inicia os containers parados (útil para retomar a operação após um stop)
#               docker compose rm
#remove os containers parados (útil para limpeza, mas cuidado com a perda de dados se os volumes não forem usados)
#               docker compose logs -f
#segue os logs em tempo real (útil para monitoramento contínuo)
#               docker compose ps -a
#lista todos os containers, incluindo os parados (útil para ver o histórico de containers
#               docker compose config
#exibe a configuração completa do docker-compose (útil para debug e verificação de configuração)
#               docker compose version
#exibe a versão do Docker Compose (útil para garantir compatibilidade)
#               docker compose pull
#puxa as imagens mais recentes do repositório (útil para garantir que você está usando as últimas versões das imagens base)
#               docker compose push
#envia as imagens para um repositório (útil para compartilhar suas imagens personalizadas
#               docker compose scale mariadb=3
#escalona o serviço mariadb para 3 réplicas (útil para balanceamento de carga, mas requer configuração adicional para persistência e rede)
#               docker compose down --volumes
#para tudo e remove os volumes (útil para limpeza completa, mas cuidado com a perda de dados)
#               docker compose down --rmi local
#para tudo e remove as imagens locais (útil para limpar espaço, mas cuidado com o tempo de reconstrução)
#               docker compose down --rmi all
#para tudo e remove todas as imagens (útil para limpeza completa, mas cuidado com o tempo de reconstrução)
#               docker compose down --remove-orphans
#para tudo e remove containers órfãos (útil para limpeza, mas cuidado com a perda de dados se os volumes não forem usados)
#               docker compose up -d
#inicia os containers em segundo plano (útil para não bloquear o terminal, mas cuidado para não esquecer de verificar os logs)
#               docker compose logs -f mariadb
#segue os logs do serviço mariadb em tempo real (útil para monitoramento específico do serviço)
#               docker compose exec mariadb mysql -u root -p
#acessa o cliente MySQL dentro do container mariadb (útil para administração do banco de dados) 
#               docker compose exec mariadb mysql -u root -p -e "SHOW DATABASES;"
#executa um comando SQL diretamente no container mariadb (útil para consultas rápidas ou scripts

    #environment:
    #  MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    #  MYSQL_DATABASE: ${MYSQL_DATABASE}
    #  MYSQL_USER: ${MYSQL_USER}
    #  MYSQL_PASSWORD: ${MYSQL_PASSWORD}


    #environment:
      #WORDPRESS_DB_HOST: ${WORDPRESS_DB_HOST}
      #WORDPRESS_DB_NAME: ${MYSQL_DATABASE}
      #WORDPRESS_DB_USER: ${MYSQL_USER}
      #WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}