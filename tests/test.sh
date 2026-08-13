#!/usr/bin/env bash
# End-to-end test suite for the Inception stack.
# Tests every service, HTTPS endpoints, WordPress (via WP-CLI), MariaDB, Redis, FTP and Portainer.
# Run from anywhere:  ./tests/test.sh   (or:  make test)

set -u

cd "$(dirname "$0")/.." || exit 1

COMPOSE="docker compose -f srcs/docker-compose.yml"
ENV_FILE="srcs/.env"
SKIP_START="${SKIP_START:-0}"
AUTO_START="${AUTO_START:-1}"

if [ -t 1 ]; then
    GREEN=$'\033[32m'
    RED=$'\033[31m'
    BOLD=$'\033[1m'
    RESET=$'\033[0m'
else
    GREEN=""
    RED=""
    BOLD=""
    RESET=""
fi

PASS=0
FAIL=0

say()  { printf '%s\n' "$*"; }
pass() { PASS=$((PASS + 1)); printf "  ${GREEN}PASS${RESET} %s\n" "$*"; }
fail() { FAIL=$((FAIL + 1)); printf "  ${RED}FAIL${RESET} %s\n" "$*"; }

# check <description> <command...>  ->  passes if command exits 0
check() {
    local desc="$1"
    shift
    if "$@" >/dev/null 2>&1; then pass "$desc"; else fail "$desc"; fi
}

# http_code <url> -> prints HTTP status code (ignores self-signed TLS)
http_code() { curl -sk -o /dev/null -w '%{http_code}' --max-time 10 "$1"; }

say "${BOLD}=== Inception test suite ===${RESET}"
say ""

if [ ! -f "$ENV_FILE" ]; then
    say "${RED}Missing $ENV_FILE. Copy it from a template / create it first.${RESET}"
    exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"

DOMAIN="$DOMAIN_NAME"
BASE="https://$DOMAIN"
DATA_DIR="/home/fbraune/data"

# ---------------------------------------------------------------------------
say "${BOLD}[1/7] Environment prerequisites${RESET}"
# ---------------------------------------------------------------------------
check "docker is installed"            command -v docker
check "curl is installed"              command -v curl
check "compose file is valid"          $COMPOSE config
check "hosts entry for $DOMAIN"        grep -q "$DOMAIN" /etc/hosts
check "data dir exists"                test -d "$DATA_DIR"

# ---------------------------------------------------------------------------
say ""
say "${BOLD}[2/7] Stack startup${RESET}"
# ---------------------------------------------------------------------------
RUNNING=$($COMPOSE ps -q 2>/dev/null | wc -l)
if [ "$RUNNING" -eq 0 ] && [ "$AUTO_START" -eq 1 ]; then
    say "  No containers running - starting the stack with 'make up' ..."
    if ! make up >/dev/null 2>&1; then
        say "  ${RED}Could not start the stack. Try 'make' to build first.${RESET}"
        exit 1
    fi
fi

if [ "$SKIP_START" -eq 1 ] && [ "$RUNNING" -eq 0 ]; then
    say "  ${RED}Stack not running and SKIP_START=1. Aborting.${RESET}"
    exit 1
fi

for svc in nginx wordpress redis ftp adminer static-site portainer mariadb; do
    state=$($COMPOSE ps --status running --format '{{.Name}}' 2>/dev/null | grep -c "^$svc$")
    if [ "$state" -eq 1 ]; then pass "container '$svc' is running"
    else fail "container '$svc' is running"; fi
done

# ---------------------------------------------------------------------------
say ""
say "${BOLD}[3/7] HTTP / HTTPS endpoints${RESET}"
# ---------------------------------------------------------------------------
h=$(http_code "$BASE/")
[ "$h" = "200" ] && pass "site homepage returns HTTP 200 (got $h)" || fail "site homepage returns HTTP 200 (got $h)"

h=$(http_code "$BASE/wp-login.php")
[ "$h" = "200" ] && pass "WordPress login page via PHP-FPM returns 200 (got $h)" || fail "WordPress login page via PHP-FPM returns 200 (got $h)"

h=$(http_code "$BASE/wp-admin/")
case "$h" in 200|302) pass "wp-admin reachable (got $h)" ;; *) fail "wp-admin reachable (got $h)" ;; esac

h=$(http_code "$BASE/resume/")
[ "$h" = "200" ] && pass "static site /resume/ returns 200 (got $h)" || fail "static site /resume/ returns 200 (got $h)"

h=$(http_code "$BASE/adminer")
[ "$h" = "200" ] && pass "adminer returns 200 (got $h)" || fail "adminer returns 200 (got $h)"

h=$(http_code "http://localhost:${PORTAINER_PORT:-9000}")
case "$h" in 200|302) pass "portainer reachable on :${PORTAINER_PORT} (got $h)" ;; *) fail "portainer reachable on :${PORTAINER_PORT} (got $h)" ;; esac

# ---------------------------------------------------------------------------
say ""
say "${BOLD}[4/7] WordPress (WP-CLI inside container)${RESET}"
# ---------------------------------------------------------------------------
WPE="docker exec wordpress wp --path=/var/www/html --allow-root"

check "WP core is installed"                $WPE core is-installed
check "WP core version reported"            $WPE core version
check "admin user '$WP_ADMIN_USER' exists"  $WPE user get "$WP_ADMIN_USER"
check "author user '$WP_USER' exists"       $WPE user get "$WP_USER"
check "redis-cache plugin is active"        $WPE plugin is-active redis-cache
check "WP database tables are healthy"      $WPE db check
check "object cache is connected to redis"  $WPE redis status

users=$($WPE user list --fields=user_login --format=csv 2>/dev/null | grep -cE "^(admin|$WP_ADMIN_USER)$")
# user list returns all users; ensure at least 2 exist
count=$($WPE user list --fields=ID --format=csv 2>/dev/null | grep -c .)
[ "${count:-0}" -ge 2 ] && pass "at least 2 WP users exist (found $count)" || fail "at least 2 WP users exist (found $count)"
unset users count

# ---------------------------------------------------------------------------
say ""
say "${BOLD}[5/7] MariaDB${RESET}"
# ---------------------------------------------------------------------------
check "mysql client can authenticate as $MYSQL_USER" \
    docker exec mariadb mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -h 127.0.0.1 -e "SELECT 1;" "$MYSQL_DATABASE"

wp_users=$(docker exec mariadb mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -h 127.0.0.1 -N -e \
    "SELECT COUNT(*) FROM wp_users;" "$MYSQL_DATABASE" 2>/dev/null)
[ "${wp_users:-0}" -ge 2 ] && pass "wp_users table has >= 2 rows (found $wp_users)" || fail "wp_users table has >= 2 rows (found $wp_users)"
unset wp_users

# ---------------------------------------------------------------------------
say ""
say "${BOLD}[6/7] Redis${RESET}"
# ---------------------------------------------------------------------------
check "redis replies PONG" docker exec redis redis-cli -a "$REDIS_PASSWORD" ping
check "wp-config.php contains redis settings" \
    docker exec wordpress grep -q "WP_REDIS_HOST" /var/www/html/wp-config.php

# ---------------------------------------------------------------------------
say ""
say "${BOLD}[7/7] FTP${RESET}"
# ---------------------------------------------------------------------------
check "FTP port ${FTP_PORT} is open" bash -c "nc -z -w 5 127.0.0.1 ${FTP_PORT}"
check "FTP login as $FTP_USER works" \
    curl -s --max-time 10 --user "$FTP_USER:$FTP_PASSWORD" "ftp://127.0.0.1/"

# ---------------------------------------------------------------------------
say ""
say "============================================================"
printf "${BOLD}Result: %d passed, %d failed${RESET}\n" "$PASS" "$FAIL"
say "============================================================"
[ "$FAIL" -eq 0 ]