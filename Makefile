# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: abenamar <abenamar@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/05/09 12:36:15 by abenamar          #+#    #+#              #
#    Updated: 2024/12/13 17:27:15 by abenamar         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

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
	$(RM) -r $(DATA)/mariadb && mkdir $(DATA)/mariadb
	$(RM) -r $(DATA)/wordpress && mkdir $(DATA)/wordpress

fclean: clean
	docker volume rm inception_mariadb
	docker volume rm inception_wordpress

re: fclean all

.PHONY: re down fclean clean up build all