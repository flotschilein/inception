#!/bin/bash
set -euo pipefail

# This script creates the FTP user bound to the WordPress volume and launches
# vsftpd in the foreground so that the container's PID 1 is the FTP daemon.

echo "Starting FTP setup ..."

echo "Environment summary:"
echo "  FTP_USER=${FTP_USER:-<not set>}"
echo "  DOMAIN_NAME=${DOMAIN_NAME:-<not set>}"

sed -i "s/PASV_ADDRESS_PLACEHOLDER/${DOMAIN_NAME}/g" /etc/vsftpd.conf
sed -i "s/PASV_MIN_PORT_PLACEHOLDER/${FTP_PASV_MIN}/g" /etc/vsftpd.conf
sed -i "s/PASV_MAX_PORT_PLACEHOLDER/${FTP_PASV_MAX}/g" /etc/vsftpd.conf

mkdir -p /var/run/vsftpd/empty

if ! id "${FTP_USER}" >/dev/null 2>&1; then
    echo "Creating FTP user '${FTP_USER}' ..."
    useradd -m -o -u 33 -g 33 -d /var/www/html -s /bin/bash "${FTP_USER}"
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
    echo "FTP user '${FTP_USER}' created."
else
    echo "FTP user '${FTP_USER}' already exists, skipping creation."
fi

echo "Starting vsftpd in foreground (PID 1)"
exec vsftpd /etc/vsftpd.conf
