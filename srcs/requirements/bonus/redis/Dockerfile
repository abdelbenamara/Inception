FROM alpine:3.20

RUN set -eux \	
	&& addgroup --gid 1000 --system redis \
	&& adduser --ingroup redis \
		--system --uid 999 redis \
	&& apk add --no-cache tzdata redis \
	&& mkdir /data \
	&& chown -R redis:redis /data

USER redis

WORKDIR /data

VOLUME ["/data"]

COPY --chown=root --chmod=755 tools /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 6379

STOPSIGNAL SIGQUIT

CMD ["redis-server"]
