#!/bin/sh

set -eo pipefail

ME=$(basename "$0")

auto_envsubst() {
	local template_dir="${NGINX_ENVSUBST_TEMPLATE_DIR:-/etc/nginx/templates}"
	local output_dir="${NGINX_ENVSUBST_OUTPUT_DIR:-/etc/nginx/http.d}"
	local suffix="${NGINX_ENVSUBST_TEMPLATE_SUFFIX:-.template}"
	
	[ -d "$template_dir" ] || return 0

	if [ ! -w "$output_dir" ]; then
    	echo "$ME: ERROR: $template_dir exists, but" \
			"$output_dir is not writable" >&2
    	
		return 1
  	fi

	local defined_envs="$(printf '${%s} ' $(env | cut -d'=' -f1))"
	local template relative_path output_path

	find "$template_dir" -follow -type f -name "*$suffix" -print \
		| while read -r template; do
		relative_path="${template#"$template_dir/"}"
		output_path="$output_dir/${relative_path%"$suffix"}"

		mkdir -p "$output_dir/$(dirname $relative_path)"
		echo "$ME: Running envsubst on $template to $output_path"
		envsubst "$defined_envs" < "$template" > "$output_path"
	done
}

main() {
	if [ "$1" = "nginx" ]; then
		auto_envsubst
	fi

	exec "$@"
}

main "$@"

exit $?
