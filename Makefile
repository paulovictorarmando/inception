# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: parmando <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/02/13 08:41:26 by parmando          #+#    #+#              #
#    Updated: 2026/02/13 09:46:58 by parmando         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

LOGIN = parmando

all: build up

build:
	@sudo mkdir -p /home/$(LOGIN)/data/mariadb
	@sudo mkdir -p /home/$(LOGIN)/data/wordpress
	@sudo chown -R $(USER):$(USER) /home/$(LOGIN)/data
	docker compose -f srcs/docker-compose.yml build

up:
	docker compose -f srcs/docker-compose.yml up -d

down:
	docker compose -f srcs/docker-compose.yml down

clean: down
	docker system prune -a

fclean: clean
	@docker volume ls -q | xargs -r docker volume rm
	sudo rm -rf /home/$(LOGIN)/data

re: fclean all