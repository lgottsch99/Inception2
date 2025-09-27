#-f flag: use this file as Compose conf instead of default docker-compose.yml in current dir
COMPOSE_FILE = -f srcs/docker-compose.yml

build:
	docker compose $(COMPOSE_FILE) build

up:
	docker compose $(COMPOSE_FILE) up -d 

down:
	docker compose $(COMPOSE_FILE) down

status:
	docker ps