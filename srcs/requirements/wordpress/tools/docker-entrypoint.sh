#!/usr/bin/env bash

set -eo pipefail

main() {
	if [ -s "/var/www/html/wp-config.php" ]; then
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

		if /usr/local/bin/wp config create \
			--dbhost="$WORDPRESS_DB_HOST" \
			--dbname="$WORDPRESS_DB_NAME" \
			--dbuser="$WORDPRESS_DB_USER" \
			--prompt=dbpass < $WORDPRESS_DB_PASSWORD_FILE > /dev/null; then
			echo "wp-config.php created"
		else
			echo "Failed to create wp-config.php" >&2
		fi

		sed -e 's/^\s*\(user =\).*/\1 www-data/' \
			-e 's/^\s*\(group =\).*/\1 www-data/' \
			-e 's/^\s*\(listen =\).*/\1 0.0.0.0:9000/' \
			-i /etc/php83/php-fpm.d/www.conf
	fi

	exec "$@"
}

main "$@"

exit $?
