#!/bin/sh

set -eo pipefail

_log() {
	local level="$1"

	shift
	echo "$(date -Iseconds) [$level] [Entrypoint]:" "$@"
}

_note() {
	_log "Note" "$@"
}

_error() {
	_log "ERROR" "$@" >&2
	exit 1
}

_process_sql() {
	mariadb --batch --binary-mode --skip-column-names \
		--database=mysql --skip-ssl "$@"
}

_temp_server_start() {
	_note "Waiting for temporary server startup"
	mariadbd --silent-startup --skip-networking \
		--skip-slave-start --skip-ssl "$@" &

	MARIADB_TEMP_SERVER_PID="$!"

	local i
	
	for i in {30..0}; do
		if healthcheck.sh --no-connect --innodb_initialized; then
			break
		fi

		sleep 1
	done

	if [ "$i" = 0 ]; then
		_error "Unable to start temporary server"
	fi

	_note "Temporary server started"
}

_temp_server_stop() {
	_note "Stopping temporary server"
	kill "$MARIADB_TEMP_SERVER_PID"
	wait "$MARIADB_TEMP_SERVER_PID"
	_note "Temporary server stopped"
}

_mariadb_init() {
	_note "Running mariadb-tzinfo-to-sql"
	mariadb-tzinfo-to-sql /usr/share/zoneinfo | _process_sql
	_note "Setting 'root'@'localhost' password"
	_note "Revoking all privileges and grant option from 'mysql'@'localhost'"
	_note "Granting usage privilege to 'mysql'@'localhost'"
	_note "Identifying 'mysql'@'localhost' only via unix socket"

	local create_database create_user

	if [ -n "$MYSQL_DATABASE" ]; then
		_note "Creating database '$MYSQL_DATABASE'"

		create_database="CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"

		if [ -n "$MYSQL_USER" ]; then
			_note "Creating user '$MYSQL_USER'@'%'"
			_note "Giving user '$MYSQL_USER' access to schema '$MYSQL_DATABASE'"

			create_user="GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* \
				to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
		fi
	fi

	_process_sql <<-EOSQL
		FLUSH PRIVILEGES;
		SET PASSWORD for 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');
		REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'mysql'@'localhost';
		GRANT USAGE ON *.* TO 'mysql'@'localhost' IDENTIFIED VIA unix_socket;
		$create_database
		$create_user
		FLUSH PRIVILEGES;
	EOSQL
}

_mariadb_upgrade() {
	local file="$1/system_mysql_backup_`date +%Y%m%d%H%M%S`.sql.zst"

	_note "Backing up mysql system database to $file"

	if ! mariadb-dump --skip-lock-tables --replace mysql | zstd > "$file"; then
		_error "Unable to backup system database for upgrade"
	fi

	_note "Backup complete"
	_note "Running mariadb-upgrade"
	mariadb-upgrade --upgrade-system-tables
}

main() {
	if [ "$1" = "mariadbd" ] || [ "$1" = "mysqld" ]; then
		local datadir="$(mariadbd --verbose --help \
			| grep -e '^datadir\s\+' \
			| sed -e 's/^datadir\s\+//' -e 's/\/\s*$//')"

		if [ ! -d "$datadir/mysql" ]; then
			local var

			for var in ROOT_PASSWORD DATABASE USER PASSWORD; do
				eval mysql_var="\$MYSQL_"$var
				eval mysql_file_var="\$MYSQL_"$var"_FILE"

				if [ -z "$mysql_var" ] && [ -n "$mysql_file_var" ]; then
					eval "export MYSQL_"$var"=$(cat "$mysql_file_var")"
				fi
			done

			_note "Running mariadb-install-db"
			mariadb-install-db --auth-root-authentication-method=socket \
				--auth-root-socket-user=mysql --datadir="$datadir" \
				--skip-name-resolve --skip-test-db
			_note "Starting temporary server for initialization"
			_temp_server_start
			_mariadb_init
			_temp_server_stop
			_note "MariaDB initialization complete"

			for var in ROOT_PASSWORD DATABASE USER PASSWORD; do
				eval "unset MYSQL_"$var
			done
		else
			_note "Starting temporary server for upgrade"
			_temp_server_start --skip-grant-tables
			
			if mariadb-upgrade --check-if-upgrade-is-needed; then
				_mariadb_upgrade "$datadir"
				_note "MariaDB upgrade complete"
			fi

			_temp_server_stop
		fi
	fi

	exec "$@"
}

main "$@"

exit $?
