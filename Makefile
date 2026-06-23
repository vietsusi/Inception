all: up

up:
	mkdir -p $(shell grep DATA_PATH srcs/.env | cut -d= -f2)/wordpress
# 	mkdir -p $(shell grep DATA_PATH srcs/.env | cut -d= -f2)/mariadb
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down

build:
	docker compose -f srcs/docker-compose.yml build

clean:
	docker compose -f srcs/docker-compose.yml down -v

fclean: clean
	docker system prune -af
	rm -rf $(shell grep DATA_PATH srcs/.env | cut -d= -f2)

re: fclean all

.PHONY: all up down build clean fclean re