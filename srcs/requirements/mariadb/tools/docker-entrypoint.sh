#!/bin/sh

set -eo pipefail

_note() {
	echo "$(date -Iseconds) [Note] [Entrypoint]:" "$@"
}

_process_sql() {
	mariadb --batch --binary-mode --skip-column-names \
		--database=mysql --skip-ssl "$@"
}

_temp_server_start() {
	_note "Waiting for temporary server startup"
	mariadbd --silent-startup --skip-networking --skip-slave-start --skip-ssl &
	
	MARIADB_TEMP_SERVER_PID="$!"
	
	local i
	
	for i in {30..0}; do
		if healthcheck.sh --no-connect --innodb_initialized; then
			break
		fi
		
		sleep 1
	done

	if [ "$i" = 0 ]; then
		_note "Unable to start temporary server" \
			| sed -e 's/ \[Info\] / \[ERROR\] /' >&2
		exit 1
	fi
}

_init_database() {
	_note "Running mariadb-tzinfo-to-sql"
	mariadb-tzinfo-to-sql /usr/share/zoneinfo | _process_sql
	_note "Setting 'root'@'localhost' password"
	_note "Revoking all privileges and grant option from 'mysql'@'localhost'"
	_note "Granting usage privilege to 'mysql'@'localhost'"
	_note "Identifying 'mysql'@'localhost' only via unix socket"
	
	local create_database create_user

	if [ "$MYSQL_DATABASE" != "" ]; then
		_note "Creating database '$MYSQL_DATABASE'"
		
		create_database="CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"
		
		if [ "$MYSQL_USER" != "" ]; then
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

MARIADB_TEMP_SERVER_PID=

main() {
	if [ ! -d "/var/lib/mysql/mysql" ]; then
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
			--auth-root-socket-user=mysql --datadir=/var/lib/mysql \
			--skip-name-resolve --skip-test-db
		_note "Database files initialized"	
		_note "Starting temporary server for init purposes"
		_temp_server_start
		_note "Temporary server started"
		_init_database
		_note "Stopping temporary server"
		kill "$MARIADB_TEMP_SERVER_PID"
		wait "$MARIADB_TEMP_SERVER_PID"
		_note "Temporary server stopped"
		
		for var in ROOT_PASSWORD DATABASE USER PASSWORD; do
			eval "unset MYSQL_"$var
		done
	fi	
	
	exec "$@"
}

main "$@"

exit $?
