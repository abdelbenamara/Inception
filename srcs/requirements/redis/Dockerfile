FROM alpine:3.20

RUN set -x \
	&& addgroup -S -g 1000 redis \
	&& adduser -S -G redis -u 999 redis \
	&& apk add --no-cache redis \
	&& mkdir /data && chown redis:redis /data

WORKDIR /data
VOLUME ["/data"]

EXPOSE 6379

STOPSIGNAL SIGQUIT

CMD ["redis-server", "--protected-mode", "no"]
