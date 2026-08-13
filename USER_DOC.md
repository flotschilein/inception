# User Documentation — Inception

## Services Provided

The stack provides three core services plus bonus services:

| Service | Purpose |
|---------|---------|
| **NGINX** | TLS-terminating reverse proxy (HTTPS on port 443) |
| **WordPress** | Content management system with PHP-FPM |
| **MariaDB** | Relational database storing WordPress content |
| **Redis** | In-memory cache for WordPress object caching (bonus) |
| **FTP (vsftpd)** | File upload to the WordPress volume on port 21 (bonus) |
| **Adminer** | Database management UI served at `/adminer` (bonus) |
| **Static site** | Static résumé site served at `/resume` (bonus) |
| **Portainer** | Container management UI on host port 9000 (bonus) |

## Start and Stop the Project

All commands must be run from the project root directory.

### Start
```bash
make
```
This builds all Docker images and starts the containers in detached mode.

### Stop
```bash
make down
```
Stops all containers without removing data volumes.

### Full Cleanup
```bash
make clean    # stops containers and removes volumes
make fclean   # removes all Docker images, containers, and cached builds
```

## Access the Website

Add the following line to `/etc/hosts` on the host machine:
```
127.0.0.1 fbraune.42.fr
```

Then open a browser and navigate to:
```
https://fbraune.42.fr
```

### WordPress Admin Panel
```
https://fbraune.42.fr/wp-admin
```

### Static Résumé Site
```
https://fbraune.42.fr/resume
```

### Adminer
```
https://fbraune.42.fr/adminer
```

### Portainer
```
http://localhost:9000
```

## Credentials

All configuration and credentials are loaded from the gitignored `srcs/.env` file.

| Variable | Purpose | Default |
|----------|---------|---------|
| `DOMAIN_NAME` | Domain for the website | `fbraune.42.fr` |
| `MYSQL_ROOT_PASSWORD` | MariaDB root password | set in `.env` |
| `MYSQL_DATABASE` | Database name | `wordpress` |
| `MYSQL_USER` | WordPress database user | `wpuser` |
| `MYSQL_PASSWORD` | WordPress database password | set in `.env` |
| `WP_ADMIN_USER` | WordPress admin username | `admin` |
| `WP_ADMIN_PASSWORD` | WordPress admin password | set in `.env` |
| `WP_ADMIN_EMAIL` | WordPress admin email | set in `.env` |
| `WP_USER` | Second WordPress user (author) | `editor` |
| `WP_USER_PASSWORD` | Second WordPress user password | set in `.env` |
| `WP_USER_EMAIL` | Second WordPress user email | set in `.env` |
| `REDIS_PASSWORD` | Redis password | set in `.env` |
| `FTP_USER` | FTP login | `ftpuser` |
| `FTP_PASSWORD` | FTP password | set in `.env` |

## Check Services Are Running

```bash
docker compose -f srcs/docker-compose.yml ps
```

Expected output — all eight services should show `Up`:
```
NAME            STATUS
nginx           Up
wordpress       Up
redis           Up
ftp             Up
adminer         Up
static-site     Up
portainer       Up
mariadb         Up
```

### View Logs
```bash
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
```
