#!/bin/bash
set -euo pipefail

# This script validates NGINX configuration and launches nginx in the foreground
# so that the container's PID 1 is the web server and signals are handled correctly.

echo "Starting NGINX setup ..."

echo "Environment summary:"
echo "  DOMAIN_NAME=${DOMAIN_NAME:-<not set>}"

if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    echo "Generating self-signed SSL certificate for ${DOMAIN_NAME} ..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=DE/ST=BW/L=Heilbronn/O=42/OU=Inception/CN=${DOMAIN_NAME}"
fi

sed -i "s/DOMAIN_NAME_PLACEHOLDER/${DOMAIN_NAME}/g" /etc/nginx/nginx.conf
sed -i "s/WP_FPM_PORT_PLACEHOLDER/${WP_FPM_PORT:-9000}/g" /etc/nginx/nginx.conf

echo "Checking NGINX configuration ..."

nginx -t

echo "Configuration OK."

echo "Starting NGINX in foreground (PID 1)"
exec nginx -g "daemon off;"