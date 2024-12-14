#!/usr/bin/env bash

set -eo pipefail

main() {
	if [ -s "/var/www/html/wp-config.php" ]; then
		echo "wp-config.php file already present, skipping creation"
	else
		echo "wp-config.php file not found, creating...."

		for var in DB_HOST DB_NAME DB_USER DB_PASSWORD_FILE \
			URL TITLE ADMIN_USER ADMIN_EMAIL ADMIN_PASSWORD_FILE \
			USER_LOGIN USER_EMAIL USER_PASSWORD_FILE; do
			eval wp_var="\$WORDPRESS_${var}"

			if [ -z "$wp_var" ]; then
				echo "Undefined variable WORDPRESS_"$var >&2
				exit 1
			fi
		done

		if wp config create \
			--dbhost="$WORDPRESS_DB_HOST" \
			--dbname="$WORDPRESS_DB_NAME" \
			--dbuser="$WORDPRESS_DB_USER" \
			--prompt=dbpass < $WORDPRESS_DB_PASSWORD_FILE > /dev/null \
			&& wp config set WP_REDIS_HOST "redis" > /dev/null \
			&& wp config set WP_REDIS_PORT "6379" > /dev/null; then
			echo "wp-config.php file created successfully"
		else
			echo "Failed to create wp-config.php file" >&2
		fi

		if wp core install \
			--url=$WORDPRESS_URL \
			--title=$WORDPRESS_TITLE \
			--admin_user=$WORDPRESS_ADMIN_USER \
			--admin_email=$WORDPRESS_ADMIN_EMAIL \
			--prompt=admin_password < $WORDPRESS_ADMIN_PASSWORD_FILE \
			--skip-email > /dev/null \
			&& wp plugin install redis-cache --activate > /dev/null; then
			echo "WordPress installed successfully"
		else
			echo "Failed to install WordPress"
		fi

		if wp user create \
			$WORDPRESS_USER_LOGIN \
			$WORDPRESS_USER_EMAIL \
			--prompt=user_pass < $WORDPRESS_USER_PASSWORD_FILE > /dev/null; then
			echo "WordPress user created successfully"
		else
			echo "Failed to create WordPress user"
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
