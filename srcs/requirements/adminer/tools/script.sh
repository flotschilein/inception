#!/bin/bash
set -euo pipefail

# This script launches PHP's built-in web server to serve Adminer in the
# foreground so that the container's PID 1 is the PHP process and signals are
# handled correctly. The document root is /var/www so that Adminer, located at
# /var/www/adminer/index.php, is reachable under the /adminer/ proxy path.

echo "Starting Adminer setup ..."

echo "Starting PHP built-in server in foreground (PID 1)"
exec php -S 0.0.0.0:8080 -t /var/www
