#!/bin/bash
set -e
MYSQL_ROOT_PASSWORD=$(cat "$DB_ROOT_PASSWORD_FILE")
MYSQL_PASSWORD=$(cat "$DB_PASSWORD_FILE")

: "${MYSQL_ROOT_PASSWORD:?Variável MYSQL_ROOT_PASSWORD não setada}"
: "${MYSQL_DATABASE:?Variável MYSQL_DATABASE não setada}"
: "${MYSQL_USER:?Variável MYSQL_USER não setada}"
: "${MYSQL_PASSWORD:?Variável MYSQL_PASSWORD não setada}"

mkdir -p /var/lib/mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql

    cat > /tmp/init.sql <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;
        FLUSH PRIVILEGES;
EOSQL

    mysqld --user=mysql --datadir=/var/lib/mysql --init-file=/tmp/init.sql
    rm -f /tmp/init.sql
fi

exec mysqld --bind-address=0.0.0.0 --user=mysql --datadir=/var/lib/mysql