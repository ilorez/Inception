DOCKER_COMPOSE = docker compose -f srcs/docker-compose.yml

all: prepare
	$(DOCKER_COMPOSE) up -d

start:
	$(DOCKER_COMPOSE) start

stop:
	$(DOCKER_COMPOSE) stop

up:
	$(DOCKER_COMPOSE) up -d

down:
	$(DOCKER_COMPOSE) down

# rm volumes & networks
clean:
	$(DOCKER_COMPOSE) down -v

# rm images, volumes & networks 
fclean: clean_volumes
	$(DOCKER_COMPOSE) down --rmi all -v

prepare:
	mkdir -p /home/znajdaou/data/wordpress_data
	mkdir -p /home/znajdaou/data/mariadb_data

# remove volumes folder
clean_volumes:
	sudo rm -rf /home/znajdaou/data/wordpress_data
	sudo rm -rf /home/znajdaou/data/mariadb_data

restart: stop start
re: fclean all


.PHONY: all start stop clean fclean prepare restart re up down clean_volumes

