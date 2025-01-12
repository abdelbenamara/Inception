FROM alpine:3.20

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ARG UID=10001

RUN set -eux \
	&& adduser --home /var/cache/inception --gecos inception \
    	--shell /sbin/nologin --disabled-password \
		--no-create-home --uid "${UID}" inception \
	&& apk add --no-cache ca-certificates tzdata \
		python3 py3-virtualenv \
	&& apk add --virtual .build-deps py3-pip \
	&& python3 -m venv /etc/inception/venv \
	&& . /etc/inception/venv/bin/activate \
	&& pip3 install --upgrade pip \
	&& pip3 install django django-environ gunicorn \
	&& pip3 uninstall --yes pip \
	&& apk del --no-network .build-deps

USER inception

WORKDIR /var/www/inception

VOLUME ["/var/www/inception"]

COPY --chown=root --chmod=755 tools/docker-entrypoint.sh /usr/local/bin/
COPY --chown=inception --chmod=755 tools/inception /etc/inception/

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8000

STOPSIGNAL SIGQUIT

CMD ["python3", "-m", "gunicorn", "--chdir", "/etc/inception", "config.wsgi"]
