FROM alpine:3.20

RUN set -eux \
	&& addgroup --system mysql \
	&& adduser --home /var/lib/mysql \
		--ingroup mysql --system mysql \
	&& apk add --no-cache tzdata zstd \
		mariadb mariadb-client mariadb-server-utils \
	&& mkdir -p /run/mysqld \	
	&& chown -R mysql:mysql /run/mysqld \
	&& chmod 1777 /run/mysqld

USER mysql

VOLUME ["/var/lib/mysql"]

COPY --chown=root --chmod=755 tools/ /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306

STOPSIGNAL SIGQUIT

CMD ["mariadbd", "--skip-networking=0"]
