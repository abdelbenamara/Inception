#!/usr/bin/env bash

set -eo pipefail

main() {
	if [ - "/var/www/html/wp-config.php" ]; then
		echo "wp-config.php already present, skipping creation"
	else
		echo "wp-config.php not found, creating...."

		for var in DB_HOST DB_NAME DB_USER DB_PASSWORD_FILE; do
			eval wp_var="\$WORDPRESS_${var}"

			if [ -z "$wp_var" ]; then
				echo "Undefined variable WORDPRESS_"$var >&2
				exit 1
			fi
		done

		/usr/local/bin/wp config create \
			--dbhost="$WORDPRESS_DB_HOST" \
			--dbname="$WORDPRESS_DB_NAME" \
			--dbuser="$WORDPRESS_DB_USER" \
			--prompt=dbpass < $WORDPRESS_DB_PASSWORD_FILE > /dev/null
	fi

	exec "$@"
}

main "$@"

exit $?
