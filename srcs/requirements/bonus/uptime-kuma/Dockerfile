FROM alpine:3.20

ARG UPTIME_KUMA_REPOSITORY=https://github.com/louislam/uptime-kuma
ARG UPTIME_KUMA_VERSION=1.23.16

ENV UPTIME_KUMA_IS_CONTAINER=1
ENV UPTIME_KUMA_REPOSITORY=$UPTIME_KUMA_REPOSITORY
ENV UPTIME_KUMA_VERSION=$UPTIME_KUMA_VERSION

ARG UID=10001

RUN set -eux \
    && adduser --home /var/cache/uptime-kuma --gecos uptime-kuma \
		--shell /sbin/nologin --disabled-password \
		--no-create-home --uid "${UID}" uptime-kuma \
	&& apk add --no-cache dumb-init iputils nodejs npm \
	&& apk add --virtual .build-deps git go \
	&& git clone --branch "$UPTIME_KUMA_VERSION" --single-branch \
		"$UPTIME_KUMA_REPOSITORY.git" /var/cache/uptime-kuma \
	&& npm ci --prefix /var/cache/uptime-kuma --omit=dev \
	&& npm run --prefix /var/cache/uptime-kuma download-dist \
	&& go build -x -o /var/cache/uptime-kuma/extra/healthcheck \
		/var/cache/uptime-kuma/extra/healthcheck.go \
	&& apk del --no-network .build-deps \
	&& rm -rf /var/cache/uptime-kuma/docker /var/cache/uptime-kuma/test \
		/var/cache/uptime-kuma/install.sh /var/cache/uptime-kuma/.devcontainer \
		/var/cache/uptime-kuma/.git /var/cache/uptime-kuma/.github \
	&& ln -sf /var/cache/uptime-kuma/data /data \
	&& chown -R uptime-kuma:uptime-kuma /var/cache/uptime-kuma

USER uptime-kuma

WORKDIR /data

VOLUME ["/data"]

ENTRYPOINT ["dumb-init", "--"]

EXPOSE 3001

STOPSIGNAL SIGQUIT

CMD ["npm", "start", "--prefix", "/var/cache/uptime-kuma"]
