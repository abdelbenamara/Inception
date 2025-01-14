#!/bin/sh

set -eo pipefail

main() {
	if [ ! -d "/var/www/html/staticfiles" ]; then
		cp -a /etc/inception/staticfiles /var/www/html/
	fi

	. /etc/inception/venv/bin/activate && exec "$@"
}

main "$@"

exit $?
