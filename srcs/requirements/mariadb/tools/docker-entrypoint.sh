#!/bin/sh

set -eo pipefail

_log() {
	echo "$(date -I) [Note] [Entrypoint]: $*"
}

_read_secret() {
    local secret_file="$1"
    if [ -f "$secret_file" ] && [ -r "$secret_file" ]; then
        cat "$secret_file"
    else
        echo ""
    fi
}

_process_sql() {
	mariadb --no-defaults --skip-ssl --skip-ssl-verify-server-cert \
		--database=mysql "$@"
}

docker_temp_server_start() {
	_log "Waiting for server startup"
	mariadbd --user=mysql --skip-name-resolve \
		--skip-networking=0 --silent-startup &
	MARIADB_TEMP_SERVER_PID="$!"

	local i
	for i in {10..0}; do
		if healthcheck.sh --connect --innodb_initialized > /dev/null 2>&1; then
			break
		fi
		sleep 3
	done

	if [ "$i" = 0 ]; then
		_log "Unable to start server" | sed -e 's/ \[Info\] / \[ERROR\] /' >&2
		exit 1
	fi
}

docker_setup_database() {
	_log "Running mariadb-tzinfo-to-sql"
	mariadb-tzinfo-to-sql /usr/share/zoneinfo | _process_sql
	
	_log "Running mariadb-secure-installation"
	sed -e '/^\s*#\+.*/d' <<-EOF | mariadb-secure-installation > /dev/null
		# Enter current password for root (enter for none):

		# Switch to unix_socket authentication [Y/n]
		n
		# Change the root password? [Y/n]
		Y
		# New password:
		$MYSQL_ROOT_PASSWORD
		# Re-enter new password:
		$MYSQL_ROOT_PASSWORD
		# Remove anonymous users? [Y/n]
		Y
		# Disallow root login remotely? [Y/n]
		Y
		# Remove test database and access to it? [Y/n]
		Y
		# Reload privilege tables now? [Y/n]
		Y
	EOF

	local create_database create_user
	if [ "$MYSQL_DATABASE" != "" ]; then
		_log "Creating database $MYSQL_DATABASE"
		create_database="CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"

		if [ "$MYSQL_USER" != "" ]; then
			_log "Creating user $MYSQL_USER"
			create_user="GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* \
				to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
		fi
	fi

	_process_sql --binary-mode <<-EOSQL
		FLUSH PRIVILEGES;
		$create_database
		$create_user
		FLUSH PRIVILEGES;
	EOSQL
}

main() {
	for var in ROOT_PASSWORD DATABASE USER PASSWORD; do
		eval mysql_var="\$MYSQL_${var}"
    	eval mysql_file_var="\$MYSQL_${var}_FILE"
		
		if [ -z "$mysql_var" ] && [ -n "$mysql_file_var" ]; then
			eval "export MYSQL_${var}=$(_read_secret "$mysql_file_var")"
		fi
	done

	if [ -d "/run/mysqld" ]; then
		_log "mysqld already present, skipping creation"
	else
		_log "mysqld not found, creating...."
		mkdir -p /run/mysqld
		chown -R mysql:mysql /run/mysqld
	fi

	if [ -d /var/lib/mysql/mysql ]; then
		_log "MySQL directory already present, skipping creation"
	else
		_log "Running mariadb-install-db"
		mariadb-install-db --user=mysql --datadir=/var/lib/mysql
		_log "Database files initialized"

		_log "Starting temporary server for init purposes"
		docker_temp_server_start
		_log "Temporary server started"

		docker_setup_database

		_log "Stopping temporary server"
		kill "$MARIADB_TEMP_SERVER_PID"
		wait "$MARIADB_TEMP_SERVER_PID"
		_log "Temporary server stopped"
	fi

	exec "$@"
}

main "$@"

exit $?
