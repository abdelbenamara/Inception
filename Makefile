NAME := srcs/docker-compose.yml

include $(CURDIR)/srcs/.env

DATA := /home/$(LOGIN)/data

all:
	docker compose -f $(NAME) up --build --detach

status:
	docker compose -f $(NAME) ps

down:
	docker compose -f $(NAME) down

logs:
	docker compose -f $(NAME) logs --follow

hosts:
	sed -e 's/^\(127\.0\.0\.1\).*$$/\1\tlocalhost $(DOMAIN_NAME)/' \
		-e 's/^\(127\.0\.0\.1.*\)$$/\1 www.$(DOMAIN_NAME)/'\
		-e 's/^\(127\.0\.0\.1.*\)$$/\1 $(ADMINER_DOMAIN_NAME)/' \
		-e 's/^\(127\.0\.0\.1.*\)$$/\1 $(UPTIME_KUMA_DOMAIN_NAME)/' \
		-i /etc/hosts

clean: down
	docker compose -f $(NAME) down --volumes

fclean: clean
	find -L $(DATA) -mindepth 2 -delete
	docker compose -f $(NAME) down --rmi local

re: fclean all

.PHONY: re fclean clean hosts logs down all