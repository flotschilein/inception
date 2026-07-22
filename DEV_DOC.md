# Developer Documentation — Inception

## Prerequisites

- Linux virtual machine (Debian/Ubuntu recommended)
- Docker Engine (>= 24.x)
- Docker Compose plugin (>= 2.x)
- `make` utility
- `/etc/hosts` entry: `127.0.0.1 fbraune.42.fr`

### Install Docker
```bash
sudo apt update
sudo apt install docker.io docker-compose-v2 make
sudo usermod -aG docker $USER
# log out and back in
```

## Setup

### 1. Clone the repository
```bash
git clone <repo-url> inception
cd inception
```

### 2. Configure environment variables
Create `srcs/.env` with your values:
```env
DOMAIN_NAME=fbraune.42.fr
MYSQL_ROOT_PASSWORD=<strong-root-password>
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
MYSQL_PASSWORD=<strong-db-password>
WP_ADMIN_USER=fbraune
WP_ADMIN_PASSWORD=<strong-admin-password>
```

### 3. Configure secrets (optional)
Create files in the `secrets/` directory for Docker secrets integration.

Example files are provided as templates — modify them with your actual credentials.

### 4. Add hosts entry
```bash
echo "127.0.0.1 fbraune.42.fr" | sudo tee -a /etc/hosts
```

## Build and Launch

### Build images
```bash
make build
```

### Start containers
```bash
make up
```

This creates the host directories `/home/fbraune/data/wordpress` and `/home/fbraune/data/mariadb`, then starts all containers.

## Managing Containers

### List running containers
```bash
docker compose -f srcs/docker-compose.yml ps
```

### Stop services
```bash
make down
```

### View logs
```bash
docker compose -f srcs/docker-compose.yml logs -f
```

### Enter a container
```bash
docker exec -it nginx /bin/bash
docker exec -it wordpress /bin/bash
docker exec -it mariadb /bin/bash
```

## Managing Volumes

### List volumes
```bash
docker volume ls
```

### Inspect volume location
```bash
docker volume inspect srcs_wp-volume
docker volume inspect srcs_db-volume
```

Volumes are stored on the host at:
- `/home/fbraune/data/wordpress` — WordPress site files
- `/home/fbraune/data/mariadb` — MariaDB database files

### Backup a volume
```bash
sudo tar czf wp-backup.tar.gz -C /home/fbraune/data/wordpress .
sudo tar czf db-backup.tar.gz -C /home/fbraune/data/mariadb .
```

### Restore a volume
```bash
sudo tar xzf wp-backup.tar.gz -C /home/fbraune/data/wordpress
sudo tar xzf db-backup.tar.gz -C /home/fbraune/data/mariadb
```

## Project Structure

```
inception/
├── Makefile
├── .gitignore
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
├── srcs/
│   ├── .env                    # environment variables (gitignored)
│   ├── docker-compose.yml
│   └── requirements/
│       ├── nginx/
│       │   ├── Dockerfile
│       │   ├── conf/nginx.conf
│       │   └── tools/script.sh
│       ├── wordpress/
│       │   ├── Dockerfile
│       │   └── tools/script.sh
│       ├── mariadb/
│       │   ├── Dockerfile
│       │   ├── conf/my.cnf
│       │   └── tools/script.sh
│       ├── adminer/            # bonus
│       ├── ftp/                # bonus
│       ├── redis/              # bonus
│       └── static-site/        # bonus
```

## Data Persistence

- **WordPress files**: Docker named volume `wp-volume` → `/home/fbraune/data/wordpress` on host
- **MariaDB data**: Docker named volume `db-volume` → `/home/fbraune/data/mariadb` on host
- Both volumes use the `local` driver with a bind-mount device option
- Data survives container restarts and rebuilds; only `make clean` removes it
