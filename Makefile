# Colors
RESET=$(shell echo -e "\033[0m")
GREEN=$(shell echo -e "\033[1;32m")
BLUE=$(shell echo -e "\033[1;34m")
YELLOW=$(shell echo -e "\033[1;33m")
RED=$(shell echo -e "\033[1;31m")

# Paths
DATA_PATH=/home/vinguyen/data
MARIADB_DIR=$(DATA_PATH)/mariadb
WORDPRESS_DIR=$(DATA_PATH)/wordpress

# Docker Compose File
COMPOSE_FILE=srcs/docker-compose.yml

# Targets
all:
	@echo "$(YELLOW)==> Creating MariaDB data directory...$(RESET)"
	@mkdir -p $(MARIADB_DIR)
	@echo "$(YELLOW)==> Creating WordPress data directory...$(RESET)"
	@mkdir -p $(WORDPRESS_DIR)
	@echo "$(YELLOW)==> Building and starting containers...$(RESET)"
	@$(MAKE) images
	@$(MAKE) up
	@echo "$(GREEN)==> Done!$(RESET)"

images:
	@echo "$(BLUE)==> Building Docker images...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) build

up:
	@echo "$(BLUE)==> Starting containers...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) up -d

down:
	@echo "$(RED)==> Stopping containers...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down

clean:
	@echo "$(RED)==> Removing containers, images, and volumes...$(RESET)"
	@docker compose -f $(COMPOSE_FILE) down --rmi all -v

fclean: clean
	@echo "$(RED)==> Removing data directories...$(RESET)"
	@sudo rm -rf $(DATA_DIR)
	@docker system prune --af

re: fclean all

.PHONY: all clean fclean re up down images

