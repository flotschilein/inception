COMPOSE	= docker compose
FILE	= -f srcs/docker-compose.yml

all: build up

build:
	$(COMPOSE) $(FILE) build

up:
	mkdir -p /home/fbraune/data/wordpress /home/fbraune/data/mariadb
	$(COMPOSE) $(FILE) up -d

down:
	$(COMPOSE) $(FILE) down

clean:
	$(COMPOSE) $(FILE) down -v

fclean: clean
	docker system prune -af

re: fclean all

DATA_DIR = /home/fbraune/data

reset: fclean
	rm -rf $(DATA_DIR)/wordpress $(DATA_DIR)/mariadb

help:
	@echo "============================================================"
	@echo "  Inception - available targets"
	@echo "============================================================"
	@echo "  make            = build + start all services"
	@echo "  make build      = build all Docker images"
	@echo "  make up         = start all containers"
	@echo "  make down       = stop containers (keep data)"
	@echo "  make clean      = stop containers + remove volumes"
	@echo "  make fclean     = clean + prune all Docker resources"
	@echo "  make reset      = full wipe: containers, volumes, images,"
	@echo "                    + delete all data in /home/fbraune/data"
	@echo "  make re         = full rebuild from scratch"
	@echo ""
	@echo "============================================================"
	@echo "  Services"
	@echo "============================================================"
	@echo ""
	@echo "  nginx"
	@echo "    what:  TLS reverse proxy, the only entry point (port 443)"
	@echo "    why:   all HTTP traffic hits nginx first, gets HTTPS"
	@echo "           and is routed to the right backend service"
	@echo "    how:   browse https://fbraune.42.fr"
	@echo ""
	@echo "  wordpress"
	@echo "    what:  WordPress CMS running on PHP-FPM"
	@echo "    why:   serves your website content + admin panel"
	@echo "    how:   https://fbraune.42.fr  /  /wp-admin"
	@echo "           wp-cli: docker exec -it wordpress wp ... --allow-root"
	@echo ""
	@echo "  mariadb"
	@echo "    what:  SQL database storing all WordPress content"
	@echo "    why:   persistent storage for posts, users, settings"
	@echo "    how:   manage via Adminer at /adminer"
	@echo "           cli:   docker exec -it mariadb mysql -u root -p"
	@echo ""
	@echo "  redis"
	@echo "    what:  in-memory key/value cache (bonus)"
	@echo "    why:   speeds up WordPress object caching"
	@echo "    how:   auto-configured by redis-cache plugin, nothing to do"
	@echo ""
	@echo "  ftp"
	@echo "    what:  vsftpd file server (bonus)"
	@echo "    why:   upload/download files into the WordPress volume"
	@echo "    how:   ftp://fbraune.42.fr  (user FTP_USER / FTP_PASSWORD)"
	@echo ""
	@echo "  adminer"
	@echo "    what:  lightweight database UI (bonus)"
	@echo "    why:   easy way to poke around in MariaDB"
	@echo "    how:   https://fbraune.42.fr/adminer"
	@echo ""
	@echo "  static-site"
	@echo "    what:  static resume site served by nginx (bonus)"
	@echo "    why:   plain HTML/CSS showcase page"
	@echo "    how:   https://fbraune.42.fr/resume"
	@echo ""
	@echo "  portainer"
	@echo "    what:  container management UI (bonus)"
	@echo "    why:   manage containers/images from the browser"
	@echo "    how:   http://localhost:9000"
	@echo ""

.PHONY: all build up down clean fclean re reset help
