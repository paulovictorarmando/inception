# sobe tudo reconstruindo imagens
up:
	docker compose up --build

# para containers
down:
	docker compose down

# limpa absolutamente tudo (volumes + imagens)
# útil quando quer resetar banco do zero
clean:
	docker compose down -v --rmi all --remove-orphans