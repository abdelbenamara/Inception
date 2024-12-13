#!/bin/sh

set -eo pipefail

_fail() {
	echo "$(date -I) [ERROR] [Healthcheck]: $*" >&2
}

_process_sql() {
	mariadb --no-defaults --skip-ssl --skip-ssl-verify-server-cert \
		--batch --skip-column-names "$@"
}

connect() {
	conn_status=$(_process_sql -e 'select @@skip_networking')
	return $conn_status
}

innodb_initialized()
{
	[ $(_process_sql -e "select 1 from information_schema.ENGINES \
WHERE engine='innodb' AND support in ('YES', 'DEFAULT', 'ENABLED')") = 1 ]
}

if [ $# -eq 0 ]; then
	_fail "At least one argument required"
	exit 1
fi

conn_status=

while [ "$#" -gt 0 ]; do
	case "$1" in
		--connect|--innodb_initialized)
			eval ${1#--} > /dev/null 2>&1
			if [ "$?" -ne 0 ]; then
				_fail "healthcheck $1 failed"
				exit 1
			fi
			;;
		*)
			_fail "Unknown healthcheck option $1"
			exit 1
	esac
	shift
done

if [ "$conn_status" != "0" ]; then
	# we didn't pass a connnect test, so the current status is suspicious
	# return what connect thinks.
	connect > /dev/null 2>&1
	exit $?
fi
