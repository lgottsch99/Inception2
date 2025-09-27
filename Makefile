#-f flag: use this file as Compose conf instead of default docker-compose.yml in current dir
COMPOSE_FILE = -f srcs/docker-compose.yml

build:
	sudo docker compose $(COMPOSE_FILE) build

up:
	sudo docker compose $(COMPOSE_FILE) up -d 

down:
	sudo docker compose $(COMPOSE_FILE) down

status:
	sudo docker ps