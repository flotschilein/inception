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
echo "  DOMAIN_NAME=${DOMAIN_NAME:-<not set>}"
echo "  WP_ADMIN_USER=${WP_ADMIN_USER:-<not set>}"
echo "  WP_USER=${WP_USER:-<not set>}"

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

if ! grep -q "WP_REDIS_HOST" "${WP_DIR}/wp-config.php" 2>/dev/null; then
    echo "Adding Redis configuration ..."
    sed -i "/^\\/\\* That's all, stop editing/i define('WP_REDIS_HOST', 'redis');\ndefine('WP_REDIS_PORT', 6379);\ndefine('WP_REDIS_PASSWORD', '${REDIS_PASSWORD}');\ndefine('WP_REDIS_TIMEOUT', 1);\ndefine('WP_REDIS_READ_TIMEOUT', 1);\ndefine('WP_REDIS_DATABASE', 0);" "${WP_DIR}/wp-config.php"
fi

echo "Setting permissions ..."
chown -R www-data:www-data "${WP_DIR}"

if ! wp core is-installed --path="${WP_DIR}" --allow-root 2>/dev/null; then
    echo "WordPress is not installed. Running installation ..."

    until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent 2>/dev/null; do
        echo "Waiting for MariaDB ..."
        sleep 2
    done

    wp core install \
        --path="${WP_DIR}" \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root \
        --skip-email

    echo "WordPress installed with admin user '${WP_ADMIN_USER}'."

    if ! wp user get "${WP_USER}" --path="${WP_DIR}" --allow-root 2>/dev/null; then
        wp user create \
            "${WP_USER}" \
            "${WP_USER_EMAIL}" \
            --path="${WP_DIR}" \
            --role=author \
            --user_pass="${WP_USER_PASSWORD}" \
            --allow-root
        echo "Second user '${WP_USER}' created."
    fi
else
    echo "WordPress already installed, skipping setup."
fi

if ! wp plugin is-installed redis-cache --path="${WP_DIR}" --allow-root 2>/dev/null; then
    echo "Installing Redis cache plugin ..."
    wp plugin install redis-cache --path="${WP_DIR}" --allow-root
fi

if ! wp plugin is-active redis-cache --path="${WP_DIR}" --allow-root 2>/dev/null; then
    echo "Activating Redis cache plugin ..."
    wp plugin activate redis-cache --path="${WP_DIR}" --allow-root
fi

if ! wp redis status --path="${WP_DIR}" --allow-root 2>/dev/null | grep -q "Connected"; then
    echo "Enabling Redis object cache ..."
    wp redis enable --path="${WP_DIR}" --allow-root 2>/dev/null || true
fi

echo "Binding PHP-FPM to 0.0.0.0:${WP_FPM_PORT:-9000} ..."
sed -i "s|^listen = .*|listen = 0.0.0.0:${WP_FPM_PORT:-9000}|" /etc/php/*/fpm/pool.d/www.conf

echo "Starting PHP-FPM server in foreground (PID 1)"
FPM_BIN=$(find /usr/sbin -name 'php-fpm*' -type f | head -1)
exec "$FPM_BIN" -F