FROM alpine:3.20

ARG UPTIME_KUMA_REPOSITORY=https://github.com/louislam/uptime-kuma
ARG UPTIME_KUMA_VERSION=1.23.16

ENV UPTIME_KUMA_REPOSITORY=$UPTIME_KUMA_REPOSITORY
ENV UPTIME_KUMA_VERSION=$UPTIME_KUMA_VERSION
ENV UPTIME_KUMA_IS_CONTAINER=1

RUN set -eux \
	&& addgroup --gid 1000 --system uptime-kuma \
    && adduser --ingroup uptime-kuma --system --uid 1000 uptime-kuma \
	&& apk add --no-cache dumb-init nodejs npm \
	&& apk add --virtual .build-deps git go \
	&& git clone --branch "$UPTIME_KUMA_VERSION" --single-branch \
		"$UPTIME_KUMA_REPOSITORY.git" /app/uptime-kuma \
	&& npm run --prefix /app/uptime-kuma setup \
	&& go build -x -o /app/uptime-kuma/extra/healthcheck \
		/app/uptime-kuma/extra/healthcheck.go \
	&& apk del --no-network .build-deps \
	&& rm -rf /app/uptime-kuma/docker /app/uptime-kuma/test \
		/app/uptime-kuma/install.sh /app/uptime-kuma/.devcontainer \
		/app/uptime-kuma/.git /app/uptime-kuma/.github \
	&& ln -s -f /app/uptime-kuma/data /data \
	&& chown -R uptime-kuma:uptime-kuma /app/uptime-kuma

USER uptime-kuma

WORKDIR /data

VOLUME ["/data"]

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

EXPOSE 3001

STOPSIGNAL SIGQUIT

CMD ["npm", "start", "--prefix", "/app/uptime-kuma"]
