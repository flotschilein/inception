#!/bin/sh
set -euo pipefail

echo "Starting Redis setup ..."

sed -i "s/\${REDIS_PASSWORD}/${REDIS_PASSWORD}/g" /etc/redis.conf

echo "Redis configuration ready. Starting server ..."
exec redis-server /etc/redis.conf
