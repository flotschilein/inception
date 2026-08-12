#!/bin/bash
set -euo pipefail

DATADIR="${MYSQL_DATADIR:-/var/lib/mysql}"

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld || true

if [ ! -d "${DATADIR}/mysql" ]; then
    mysql_install_db --datadir="${DATADIR}" --user=mysql >/dev/null
    chown -R mysql:mysql "${DATADIR}" || true

    mysqld --datadir="${DATADIR}" --user=mysql --skip-networking --socket=/tmp/mysql.sock &
    PID="$!"

    for i in $(seq 30); do
        if mysqladmin ping --socket=/tmp/mysql.sock --silent 2>/dev/null; then
            break
        fi
        sleep 1
    done

    mysql --socket=/tmp/mysql.sock -u root << stuff
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
stuff

    mysqladmin --socket=/tmp/mysql.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$PID"
fi

exec mysqld --datadir="${DATADIR}" --user=mysql