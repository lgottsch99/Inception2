#TODO move makefile outside srcs

COMPOSE_FILE = -f srcs/docker-compose.yml

build:
	sudo docker compose $(COMPOSE_FILE) build

up:
	sudo docker compose $(COMPOSE_FILE) up -d 

down:
	sudo docker compose $(COMPOSE_FILE) down

status:
	sudo docker ps