#!/usr/bin/env bash

set -eo pipefail

main() {
	wpEnvs=( "${!WORDPRESS_@}" )
	
	if [ ! -s "wp-config.php" ] && [ "${#wpEnvs[@]}" -gt 0 ]; then
		if [ -s "wp-config-docker.php" ]; then
			echo >&2 "No 'wp-config.php' found in $PWD, but 'WORDPRESS_...'" \
				"variables supplied; copying '$wpConfigDocker' (${wpEnvs[*]})"
			# using "awk" to replace all instances of 
			# "put your unique phrase here" with a properly unique string 
			# (for AUTH_KEY and friends to have safe defaults 
			# if they aren't specified with environment variables)
			awk '
				/put your unique phrase here/ {
					cmd = "head -c1m /dev/urandom | sha1sum | cut -d\\  -f1"
					cmd | getline str
					close(cmd)
					gsub("put your unique phrase here", str)
				}
				{ print }
			' "$wpConfigDocker" > wp-config.php
			if [ "$(id -u)" = '0' ]; then
				# attempt to ensure that wp-config.php is owned by the run user
				# could be on a filesystem that doesn't allow chown 
				# (like some NFS setups)
				chown "www-data:www-data" wp-config.php || true
			fi
		fi
	fi

	exec "$@"
}

main "$@"

exit $?
