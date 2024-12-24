#!/bin/sh

set -eo pipefail

main() {
    if [ "$1" = "redis-server" ] && ! redis-cli ping > /dev/null 2>&1; then
        for var in DEFAULT_PASSWORD_FILE \
            USER PASSWORD_FILE; do
            eval redis_var="\$REDIS_"$var

            if [ -z "$redis_var" ]; then
                echo "Undefined variable REDIS_"$var >&2
                exit 1
            fi
        done

        set -- "$@" "--requirepass" "$(cat $REDIS_DEFAULT_PASSWORD_FILE)" \
            "--user" "$REDIS_USER" "on" "allkeys" "allcommands" "allchannels" \
            ">$(cat $REDIS_PASSWORD_FILE)"
    fi

    exec "$@"
}

main "$@"

exit $?
