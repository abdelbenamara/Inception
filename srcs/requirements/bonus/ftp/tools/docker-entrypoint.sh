#!/bin/sh

set -eo pipefail

auto_envsubst() {
	local source="${VSFTPD_ENVSUBST_TEMPLATE:-/etc/vsftpd/vsftpd.conf.template}"
	local target="/etc/vsftpd.conf"
	
	[ -e "$source" ] || return 0

	local defined_envs="$(printf '${%s} ' $(env | cut -d'=' -f1))"

	echo "Running envsubst on $source to $target"
	envsubst "$defined_envs" < "$source" > "$target"
}

main() {
	if [ "$1" = "vsftpd" ]; then
		if ! id -u "$FTP_USER" > /dev/null 2>&1; then
			local ingroup uid

			if [ -n "$FTP_GROUP" ]; then
				if [ -n "$FTP_GID" ]; then
					addgroup --gid "$FTP_GID" --system "$FTP_GROUP"
				fi

				ingroup="--ingroup $FTP_GROUP"
			fi

			if [ -n "$FTP_UID" ]; then
				uid="--uid ${FTP_UID}"
			fi

			adduser --home "/var/ftp/$FTP_USER" --gecos "$FTP_USER" \
				--shell /sbin/nologin $ingroup --disabled-password \
				--system --no-create-home $uid "$FTP_USER"
			mkdir -p "/var/ftp/$FTP_USER"
				
			if [ -n "$FTP_GROUP" ]; then
				chown -R "$FTP_USER:$FTP_GROUP" "/var/ftp/$FTP_USER"
			else
				chown -R "$FTP_USER:" "/var/ftp/$FTP_USER"
			fi

			if [ -n "$FTP_PASSWORD_FILE" ]; then
				echo "$FTP_USER:$(cat $FTP_PASSWORD_FILE)" | chpasswd
			else
				echo "$FTP_USER password is disabled and cannot login" >&2
				exit 1
			fi
		fi

		auto_envsubst
	fi

	exec "$@"
}

main "$@"

exit $?
