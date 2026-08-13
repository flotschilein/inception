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
# optional port customization
NGINX_PORT=443
WP_FPM_PORT=9000
FTP_PORT=21
FTP_PASV_MIN=21000
FTP_PASV_MAX=21099
PORTAINER_PORT=9000
```

### 3. Add hosts entry
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
docker exec -it redis sh
docker exec -it ftp /bin/bash
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
docker volume inspect srcs_portainer-data
```

Volumes are stored on the host at:
- `/home/fbraune/data/wordpress` — WordPress site files
- `/home/fbraune/data/mariadb` — MariaDB database files
- Portainer data is kept in the Docker-managed named volume `portainer-data`

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
└── srcs/
    ├── .env                    # environment variables (gitignored)
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/nginx.conf
        │   └── tools/script.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/script.sh
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/my.cnf
        │   └── tools/script.sh
        ├── redis/              # bonus
        │   ├── Dockerfile
        │   ├── conf/redis.conf
        │   └── tools/script.sh
        ├── ftp/                # bonus
        │   ├── Dockerfile
        │   ├── conf/vsftpd.conf
        │   └── tools/script.sh
        ├── adminer/            # bonus
        │   ├── Dockerfile
        │   └── tools/script.sh
        ├── static-site/        # bonus
        │   ├── Dockerfile
        │   ├── conf/nginx.conf
        │   └── website/
        │       ├── index.html
        │       └── style.css
        └── portainer/          # bonus
            ├── Dockerfile
            └── .dockerignore
```

## Data Persistence

- **WordPress files**: Docker named volume `srcs_wp-volume` → `/home/fbraune/data/wordpress` on host
- **MariaDB data**: Docker named volume `srcs_db-volume` → `/home/fbraune/data/mariadb` on host
- **Portainer data**: Docker named volume `portainer-data` managed by Docker (`/var/lib/docker/volumes/`)
- The WordPress and MariaDB volumes use the `local` driver with a bind-mount device option
- Data survives container restarts and rebuilds; only `make clean` removes it
