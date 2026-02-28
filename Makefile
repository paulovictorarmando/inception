COMPOSE = docker compose -f ./srcs/docker-compose.yml
DATA = /home/parmando/data

all: setup up

setup:
	@mkdir -p $(DATA)/wordpress
	@mkdir -p $(DATA)/mariadb
	@chmod 755 $(DATA)/wordpress
	@chmod 755 $(DATA)/mariadb

build:
	@$(COMPOSE) build

up:
	@$(COMPOSE) up -d --build

down:
	@$(COMPOSE) down

clean:
	@$(COMPOSE) down -v --rmi all --remove-orphans

fclean: clean
	@rm -rf $(DATA)

re: fclean all