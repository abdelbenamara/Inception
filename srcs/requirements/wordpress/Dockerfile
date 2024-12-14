FROM alpine:3.20

RUN set -x \
	&& adduser -u 82 -D -S -G www-data www-data \
	&& apk add --no-cache bash php83 php83-phar php83-mbstring php83-fpm \
		fcgi php83-cgi mariadb-client php83-mysqli \
	&& wget -O /usr/local/bin/wp \
	https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /usr/local/bin/wp \
	&& mkdir -p /var/www/html \
	&& /usr/local/bin/wp core download --path=/var/www/html \
	&& chown -R www-data:www-data /var/www/html \
	&& chmod 1777 /var/www/html

WORKDIR /var/www/html
VOLUME ["/var/www/html"]

COPY --chown=root --chmod=755 tools /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 9000

STOPSIGNAL SIGQUIT

CMD ["php-fpm83", "-F", "-O"]
