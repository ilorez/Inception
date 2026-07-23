DOCKER_COMPOSE = docker compose -f srcs/docker-compose.yml

all: prepare
	$(DOCKER_COMPOSE) up -d

start: prepare
	$(DOCKER_COMPOSE) up -d

stop:
	$(DOCKER_COMPOSE) down

# rm volumes & networks
clean:
	$(DOCKER_COMPOSE) down -v

# rm images, volumes & networks 
fclean:
	$(DOCKER_COMPOSE) down --rmi all -v

prepare:
	mkdir -p /home/znajdaou/data/wordpress_data
	mkdir -p /home/znajdaou/data/mariadb_data


.PHONY: all start stop clean fclean prepare

