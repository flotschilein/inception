#!/bin/bash
set -euo pipefail

# This script initializes WordPress configuration if needed and then launches PHP-FPM
# in the foreground so that the container's PID 1 is the PHP process and signals are handled correctly.

WP_DIR="/var/www/html"

echo "Using WordPress directory: ${WP_DIR}"

echo "Environment summary:"
echo "  MYSQL_DATABASE=${MYSQL_DATABASE:-<not set>}"
echo "  MYSQL_USER=${MYSQL_USER:-<not set>}"
echo "  MYSQL_PASSWORD=${MYSQL_PASSWORD:-<not set>}"

if [ ! -f "${WP_DIR}/wp-config.php" ]; then
    echo "wp-config.php not found, initializing configuration ..."

    cp "${WP_DIR}/wp-config-sample.php" "${WP_DIR}/wp-config.php"

    echo "Applying database configuration ..."

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" "${WP_DIR}/wp-config.php"
    sed -i "s/username_here/${MYSQL_USER}/" "${WP_DIR}/wp-config.php"
    sed -i "s/password_here/${MYSQL_PASSWORD}/" "${WP_DIR}/wp-config.php"
    sed -i "s/localhost/mariadb/" "${WP_DIR}/wp-config.php"

    echo "Configuration complete."
else
    echo "Configuration already exists, skipping initialization."
fi

echo "Setting permissions ..."
chown -R www-data:www-data "${WP_DIR}"

echo "Starting PHP-FPM server in foreground (PID 1)"
exec php-fpm7.4 -F