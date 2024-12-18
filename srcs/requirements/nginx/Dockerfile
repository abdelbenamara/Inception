FROM alpine:3.20

RUN set -x \
	&& addgroup --gid 101 --system nginx \
	&& adduser --home /var/cache/nginx --gecos nginx \
		--shell /sbin/nologin --ingroup nginx --system \
		--disabled-password --no-create-home \
		--uid 101 nginx \
	&& apk add --no-cache gettext tzdata nginx \
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY --chown=root --chmod=755 tools /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 443

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
