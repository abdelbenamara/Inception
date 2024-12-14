NAME := srcs/docker-compose.yml

include $(CURDIR)/srcs/.env

DATA := /home/$(LOGIN)/data

RM := rm -f

all: build up

build:
	docker compose -f $(NAME) build

up:
	docker compose -f $(NAME) up -d

down:
	docker compose -f $(NAME) down

clean: down
	$(RM) -r $(DATA)/wordpress/*
	$(RM) -r $(DATA)/mariadb/*
	$(RM) -r $(DATA)/redis/*

fclean: clean
	docker volume rm inception_wordpress
	docker volume rm inception_mariadb
	docker volume rm inception_redis

re: fclean all

.PHONY: re down fclean clean up build all