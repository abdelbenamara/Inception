# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: abenamar <abenamar@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/05/09 12:36:15 by abenamar          #+#    #+#              #
#    Updated: 2024/06/30 21:48:30 by abenamar         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME := srcs/docker-compose.yml

DATA := data

RM := rm -f

all: up

build:
	docker compose -f $(NAME) build

up:
	docker compose -f $(NAME) up -d

clean:
	$(RM) -r $(DATA)

down:
	docker compose -f $(NAME) down

re: down clean up

.PHONY: re down clean up build all
