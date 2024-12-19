#!/bin/sh

set -eo pipefail

_error() {
	echo "$(date -Iseconds) [ERROR] [Healthcheck]:" "$@" >&2
	exit 1
}

_process_sql() {
	mariadb --batch --skip-column-names --skip-ssl "$@"
}

CONNECTION_STATUS=

_connect() {
	CONNECTION_STATUS=$(_process_sql -e 'select @@skip_networking')
	
	return $CONNECTION_STATUS
}

_innodb_initialized()
{
	[ $(_process_sql -e "select 1 from information_schema.ENGINES WHERE \
		engine='innodb' AND support in ('YES', 'DEFAULT', 'ENABLED')") = 1 ]
}

main() {
	if [ $# -eq 0 ]; then
		_error "At least one argument required"
	fi

	while [ $# -gt 0 ]; do
		case "$1" in
			--no-connect)
				CONNECTION_STATUS=0
				;;
			--connect|--innodb_initialized)
				eval "_${1#--} > /dev/null 2>&1"
				
				if [ $? -ne 0 ]; then
					_error "Test '$1' failed"
				fi
				
				;;
			*)
				_error "Unknown option or test '$1'"
				;;
		esac

		shift
	done

	if [ "$CONNECTION_STATUS" != "0" ]; then
		connect > /dev/null 2>&1
	fi	
	
	return $CONNECTION_STATUS
}

main "$@"

exit $?
