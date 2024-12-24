FROM alpine:3.20

RUN set -x \
	&& adduser --ingroup www-data --disabled-password --system \
		--uid 82 www-data \
	&& apk add --no-cache bash ghostscript imagemagick \
		php83 php83-fpm php83-phar php83-ctype php83-json php83-mysqli \
		php83-gd php83-mbstring php83-tokenizer php83-xml php83-curl \
		php83-dom php83-exif php83-fileinfo php83-zip php83-iconv php83-intl \
		php83-opcache php83-pecl-imagick php83-redis \
	&& wget -O /usr/local/bin/wp \
	https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /usr/local/bin/wp \
	&& mkdir -p /var/www/html \
	&& wp core download --path=/var/www/html \
	&& sed -e 's/^\s*\(user =\).*/\1 www-data/' \
		-e 's/^\s*\(group =\).*/\1 www-data/' \
		-e 's/^\s*\(listen =\).*/\1 0.0.0.0:9000/' \
		-i /etc/php83/php-fpm.d/www.conf

WORKDIR /var/www/html

VOLUME ["/var/www/html"]

COPY --chown=root --chmod=755 tools /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 9000

STOPSIGNAL SIGQUIT

CMD ["php-fpm83", "--nodaemonize", "--force-stderr"]
