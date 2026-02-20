# *1* - criar estrutura de pastas

# *2* - criar docker-compose vazio

# *3* - subir só mariadb

# *4* - depois wordpress

# *5* - por último nginx + ssl

##
### Makefile

Só para facilitar:

make up


make down


make build


make clean

##
services:
  mariadb:
    build: ./srcs/requirements/mariadb
    image: mariadb
    container_name: mariadb

  wordpress:
    build: ./srcs/requirements/wordpress
    image: wordpress
    container_name: wordpress

  nginx:
    build: ./srcs/requirements/nginx
    image: nginx
    container_name: nginx

##

Teste rápido de MariaDB:

sudo docker ps

Deve aparecer o container mariadb rodando

Logs:

sudo docker logs mariadb

Conexão dentro do container:

sudo docker exec -it mariadb mysql -u root -p
# senha: a que você colocou no .env