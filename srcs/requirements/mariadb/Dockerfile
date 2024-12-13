FROM alpine:3.20

RUN set -x \
	&& addgroup -S mysql \
	&& adduser -S mysql -G mysql -h /var/lib/mysql \
	&& apk add --no-cache tzdata mariadb mariadb-client

VOLUME ["/var/lib/mysql"]

COPY --chown=root --chmod=755 tools /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 3306

STOPSIGNAL SIGQUIT

CMD ["mariadbd", "--user=mysql", "--skip-networking=0"]
