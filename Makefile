NAME := srcs/docker-compose.yml

include $(CURDIR)/srcs/.env

DATA := /home/$(LOGIN)/data

RM := rm -f

all:
	docker compose -f $(NAME) up --build --detach

down:
	docker compose -f $(NAME) down

logs:
	docker compose -f $(NAME) logs --follow

clean: down
	docker compose -f $(NAME) down --volumes

fclean: clean
	$(RM) -r /home/$(LOGIN)/data/**/*
	docker compose -f $(NAME) down --rmi local

re: fclean all

.PHONY: re fclean clean logs down all