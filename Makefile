# user username from .env
include ./srcs/.env
export


DOCKER_COMPOSE = docker compose -f srcs/docker-compose.yml
RM = rm -rf

all: up

start:
	$(DOCKER_COMPOSE) start

stop:
	$(DOCKER_COMPOSE) stop

up: prepare
	$(DOCKER_COMPOSE) up --build

down:
	$(DOCKER_COMPOSE) down

# rm volumes & networks
clean:
	$(DOCKER_COMPOSE) down -v

# rm images, volumes & networks 
fclean: clean_volumes
	$(DOCKER_COMPOSE) down --rmi all -v

prepare:
	mkdir -p /home/$(USERNAME)/data/wordpress_data
	mkdir -p /home/$(USERNAME)/data/mariadb_data

# remove volumes folder
clean_volumes:
	sudo $(RM) /home/$(USERNAME)/data/wordpress_data
	sudo $(RM) /home/$(USERNAME)/data/mariadb_data

logs:
	$(DOCKER_COMPOSE) logs -f

restart: stop start
re: fclean all
rebuild: down up


.PHONY: all start stop clean fclean prepare restart re up down clean_volumes rebuild logs

