#!/bin/bash
set -euo pipefail

# This script validates NGINX configuration and launches nginx in the foreground
# so that the container's PID 1 is the web server and signals are handled correctly.

echo "Starting NGINX setup ..."

echo "Environment summary:"
echo "  DOMAIN_NAME=${DOMAIN_NAME:-<not set>}"

sed -i "s/DOMAIN_NAME_PLACEHOLDER/${DOMAIN_NAME}/" /etc/nginx/nginx.conf

echo "Checking NGINX configuration ..."

nginx -t

echo "Configuration OK."

echo "Starting NGINX in foreground (PID 1)"
exec nginx -g "daemon off;"