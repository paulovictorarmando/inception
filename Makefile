COMPOSE = docker compose -f ./srcs/docker-compose.yml
DATA = /home/parmando/data
DATA_TEST = /home/paulo-armando/data

all: setup up

setup:
	@mkdir -p $(DATA_TEST)/wordpress
	@mkdir -p $(DATA_TEST)/mariadb
	@chmod 755 $(DATA_TEST)/wordpress
	@chmod 755 $(DATA_TEST)/mariadb

build:
	@$(COMPOSE) build

up:
	@$(COMPOSE) up -d --build

down:
	@$(COMPOSE) down

clean:
	@$(COMPOSE) down -v --rmi all --remove-orphans

fclean: clean
	@sudo rm -rf $(DATA_TEST)

re: fclean all