*This project has been created as part of the 42 curriculum by fbraune.*

## Description

Inception is a system administration project that involves setting up a small infrastructure of Docker containers to host a WordPress website. The project uses Docker Compose to orchestrate multiple services — NGINX with TLS, WordPress with PHP-FPM, and MariaDB — each running in its own dedicated container built from custom Dockerfiles based on Debian Bookworm.

The infrastructure is designed with security, isolation, and persistence in mind: NGINX is the only entry point (port 443), containers restart on failure, and persistent data is stored in Docker named volumes mapped to the host machine.

## Instructions

### Prerequisites
- Docker and Docker Compose installed on a Linux virtual machine
- The domain `fbraune.42.fr` must resolve to `127.0.0.1` in `/etc/hosts`:
  ```
  127.0.0.1 fbraune.42.fr
  ```

### Build and Launch
```bash
make          # builds images and starts containers
make build    # builds images only
make up       # starts containers (creates host volumes)
make down     # stops containers
make clean    # stops and removes volumes
make fclean   # clean + prune all Docker resources
make re       # full rebuild
```

### Access
- Website: https://fbraune.42.fr
- WordPress admin: https://fbraune.42.fr/wp-admin

## Project Description

This project uses Docker to virtualize three services in isolated containers:

- **NGINX** — TLSv1.2/TLSv1.3 reverse proxy, sole entry point on port 443
- **WordPress + PHP-FPM** — serves the CMS via FastCGI on port 9000
- **MariaDB** — relational database on port 3306

All containers are connected through a dedicated Docker bridge network and use named volumes for persistent storage.

### Virtual Machines vs Docker

| Virtual Machines | Docker |
|----------------|--------|
| Each VM runs a full OS with its own kernel | Containers share the host kernel |
| Heavy resource usage (GBs of RAM/disk) | Lightweight (MBs per container) |
| Slow to boot (minutes) | Instant startup (seconds) |
| Hardware-level isolation | Process-level isolation via cgroups/namespaces |

### Secrets vs Environment Variables

| Secrets | Environment Variables |
|---------|---------------------|
| Designed for sensitive data (passwords, keys) | Visible in process lists, logs, and Docker inspect |
| Stored in encrypted files or dedicated secret stores | Stored in plaintext in `.env` files |
| Can be rotated without rebuilding images | Require restart or rebuild to change |
| More secure for production | Simpler for development |

In this project, secrets are stored in the `secrets/` directory and can be integrated with Docker's built-in secrets mechanism for enhanced security.

### Docker Network vs Host Network

| Docker Network | Host Network |
|---------------|-------------|
| Containers get isolated IPs on a virtual bridge | Containers share the host's network stack |
| Containers communicate via internal DNS (service names) | Port conflicts possible |
| Network isolation prevents unwanted external access | No isolation between host and container |
| Default and recommended approach | Forbidden in this project |

This project uses a custom bridge network named `inception` to isolate container communication.

### Docker Volumes vs Bind Mounts

| Docker Volumes | Bind Mounts |
|---------------|-------------|
| Managed by Docker (`docker volume`) | Direct host directory mapping |
| Stored in `/var/lib/docker/volumes/` by default | Point to any host path |
| Portable and backup-friendly | Host-path dependent |
| This project uses named volumes with `device` option pointing to `/home/fbraune/data/` | Used in the compose file via `driver_opts` with `type: none` and `o: bind` |

## Resources

### Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Installation](https://wordpress.org/documentation/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.php)
- [OpenSSL Documentation](https://www.openssl.org/docs/)

### AI Usage
AI (opencode) was used to assist with:
- Help writing documentation (README, USER_DOC, DEV_DOC)
- Debugging configuration issues
- Generating the `.env` file and credential placeholders

All AI-generated code and text was reviewed, tested, and understood before inclusion.
