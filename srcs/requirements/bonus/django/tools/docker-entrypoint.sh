#!/bin/sh

set -eo pipefail

main() {
	if [ ! -d "/var/www/inception/staticfiles" ]; then
		cp -a /etc/inception/staticfiles /var/www/inception/
	fi

	. /etc/inception/venv/bin/activate && exec "$@"
}

main "$@"

exit $?
