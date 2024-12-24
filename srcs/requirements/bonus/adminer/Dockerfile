FROM alpine:3.20

ARG ADMINER_REPOSITORY=https://github.com/vrana/adminer
ARG ADMINER_VERSION=4.8.1

ENV ADMINER_REPOSITORY=$ADMINER_REPOSITORY
ENV ADMINER_VERSION=$ADMINER_VERSION

RUN set -x \
	&& addgroup --system adminer \
    && adduser --ingroup adminer --system adminer \
	&& apk add --no-cache php83 php83-fpm php83-session php83-mysqli \
		php83-pdo_pgsql php83-pdo_sqlite php83-pdo_odbc php83-pdo_dblib \
	&& mkdir -p /var/www/admin \
	&& wget -O /var/www/admin/adminer.php "$ADMINER_REPOSITORY\
/releases/download/v$ADMINER_VERSION/adminer-$ADMINER_VERSION.php" \
	&& apk add --virtual .build-deps git \
	&& git clone --recurse-submodules=designs --depth 1 --shallow-submodules \
		--branch "v$ADMINER_VERSION" "$ADMINER_REPOSITORY.git" /tmp/adminer \
    && apk del --no-network .build-deps \
	&& mv /tmp/adminer/designs/ /tmp/adminer/plugins/ /var/www/admin/ \
	&& rm -rf /tmp/adminer/ \
	&& chown -R adminer:adminer /var/www/admin \
	&& sed -e 's/^\s*\(user =\).*/\1 adminer/' \
		-e 's/^\s*\(group =\).*/\1 adminer/' \
		-e 's/^\s*\(listen =\).*/\1 0.0.0.0:9000/' \
		-i /etc/php83/php-fpm.d/www.conf

WORKDIR /var/www/admin

VOLUME ["/var/www/admin"]

COPY --chown=root --chmod=755 tools /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 9000

STOPSIGNAL SIGQUIT

CMD ["php-fpm83", "--nodaemonize", "--force-stderr"]
