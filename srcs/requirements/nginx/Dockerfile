FROM alpine:3.20

RUN set -x \
	&& addgroup -g 101 -S nginx \
	&& adduser \
		-S -D -H -u 101 -h /var/cache/nginx \
		-s /sbin/nologin -G nginx -g nginx nginx \
	&& apk add --no-cache gettext tzdata nginx \
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

COPY --chown=root --chmod=755 tools /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 443

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
