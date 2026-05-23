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

.PHONY: all build up down clean fclean re
