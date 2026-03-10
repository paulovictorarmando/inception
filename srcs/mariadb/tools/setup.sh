#!/bin/bash
set -e

MYSQL_ROOT_PASSWORD=$(cat "$DB_ROOT_PASSWORD_FILE")
MYSQL_PASSWORD=$(cat "$DB_USER_PASSWORD_FILE")

: "${MYSQL_ROOT_PASSWORD:?Variável MYSQL_ROOT_PASSWORD não setada}"
: "${MYSQL_DATABASE:?Variável MYSQL_DATABASE não setada}"
: "${MYSQL_USER:?Variável MYSQL_USER não setada}"
: "${MYSQL_PASSWORD:?Variável MYSQL_PASSWORD não setada}"

SOCKET_PATH=/run/mysqld/mysqld.sock

mkdir -p /var/lib/mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
fi

# Start a temporary server bound to localhost so we can run idempotent SQL.
mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=127.0.0.1 --socket="$SOCKET_PATH" &
temp_pid="$!"

until mysqladmin --socket="$SOCKET_PATH" ping --silent; do
    sleep 1
done

ROOT_AUTH=( -uroot -p"$MYSQL_ROOT_PASSWORD" )
if ! mysql --socket="$SOCKET_PATH" "${ROOT_AUTH[@]}" -e 'SELECT 1' >/dev/null 2>&1; then
    ROOT_AUTH=( -uroot )
fi

mysql --socket="$SOCKET_PATH" "${ROOT_AUTH[@]}" <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

mysqladmin --socket="$SOCKET_PATH" -uroot -p"$MYSQL_ROOT_PASSWORD" shutdown 2>/dev/null || \
mysqladmin --socket="$SOCKET_PATH" -uroot shutdown 2>/dev/null || \
kill -TERM "$temp_pid"

wait "$temp_pid" 2>/dev/null || true

exec mysqld --bind-address=0.0.0.0 --user=mysql --datadir=/var/lib/mysql --socket="$SOCKET_PATH"