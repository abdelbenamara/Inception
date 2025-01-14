FROM alpine:3.20

ARG GID=10001
ARG UID=10001

ENV FTP_USER=ftpsecure

RUN set -eux \
    && addgroup --gid "$GID" --system ftpsecure \ 
    && adduser --home /var/ftp/ftpsecure --gecos ftpsecure \
        --shell /sbin/nologin --ingroup ftpsecure \
        --system --disabled-password --no-create-home \
        --uid "$UID" ftpsecure \
    && apk add --no-cache dumb-init gettext vsftpd \
    && ln -sf /proc/1/fd/1 /var/log/vsftpd.log

COPY --chown=root --chmod=755 tools/ /usr/local/bin/

ENTRYPOINT ["dumb-init", "--", "docker-entrypoint.sh"]

EXPOSE 21

STOPSIGNAL SIGQUIT

CMD ["vsftpd"]
