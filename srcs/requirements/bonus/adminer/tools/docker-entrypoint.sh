#!/bin/sh

set -eo pipefail

main() {
    if [ "$1" = "php-fpm83" ] && [ ! -e "index.php" ]; then
        if [ -n "$ADMINER_DESIGN" ]; then
            ln -sf "designs/$ADMINER_DESIGN/adminer.css" adminer.css
            echo "Adminer set up with '$ADMINER_DESIGN' alternative design"
        fi

        if [ ! -s "/etc/adminer/index.php" ]; then
            echo "Adminer '/etc/adminer/index.php' not found" >&2
            exit 1
        fi

        cp /etc/adminer/index.php index.php
        chown www-data:www-data index.php
        echo "Adminer v$ADMINER_VERSION initialized"
    fi

    exec "$@"
}

main "$@"

exit $?
