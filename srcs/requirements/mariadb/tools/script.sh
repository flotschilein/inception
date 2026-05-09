#!/bin/bash
set -euo pipefail

# This script initializes MariaDB data dir if needed and launches mysqld in
# the foreground  so that the container's PID 1 is the database server and signals are handled correctly.

DATADIR="${MYSQL_DATADIR:-/var/lib/mysql}"

echo "Using datadir: ${DATADIR}"

echo "Environment summary:"
echo "  MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-<not set>}"
echo "  MYSQL_DATABASE=${MYSQL_DATABASE:-<not set>}"
echo "  MYSQL_USER=${MYSQL_USER:-<not set>}"
echo "  MYSQL_PASSWORD=${MYSQL_PASSWORD:-<not set>}"

if [ ! -d "${DATADIR}/mysql" ]; then
    echo "Data directory not found, initializing MariaDB data files ..."

    if command -v mysql_install_db >/dev/null 2>&1; then
        echo "Using mysql_install_db to create initial database files"
        mysql_install_db --datadir="${DATADIR}" --user=mysql >/dev/null
    else
        echo "mysql_install_db not found, falling back to mysqld --initialize-insecure"
        mysqld --initialize-insecure --datadir="${DATADIR}" --user=mysql
    fi

    chown -R mysql:mysql "${DATADIR}" || true
    echo "Initialization complete. No init SQL will be executed by this script."
fi


echo "Starting MariaDB server in foreground (PID 1)"
# Exec so that mysqld becomes PID 1 and receives signals from the container
exec mysqld --datadir="${DATADIR}"