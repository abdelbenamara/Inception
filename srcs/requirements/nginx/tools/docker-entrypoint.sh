#!/bin/sh

set -eo pipefail

ME=$(basename "$0")

auto_envsubst() {
	local template_dir="${NGINX_ENVSUBST_TEMPLATE_DIR:-/etc/nginx/templates}"
	local suffix="${NGINX_ENVSUBST_TEMPLATE_SUFFIX:-.template}"
	local output_dir="${NGINX_ENVSUBST_OUTPUT_DIR:-/etc/nginx/http.d}"

	local template defined_envs relative_path output_path subdir
	defined_envs=$(printf '${%s} ' $(awk "END { for (name in ENVIRON) \
		{ print ( name ~ /${filter}/ ) ? name : \"\" } }" < /dev/null ))
	[ -d "$template_dir" ] || return 0
	if [ ! -w "$output_dir" ]; then
    	echo "$ME: ERROR: $template_dir exists, but $output_dir is not writable"
    	return 0
  	fi
		find "$template_dir" -follow -type f -name "*$suffix" -print \
			| while read -r template; do
		relative_path="${template#"$template_dir/"}"
		output_path="$output_dir/${relative_path%"$suffix"}"
		subdir=$(dirname "$relative_path")
		mkdir -p "$output_dir/$subdir"
		echo "$ME: Running envsubst on $template to $output_path"
		envsubst "$defined_envs" < "$template" > "$output_path"
	done
}

main() {
	auto_envsubst

	exec "$@"
}

main "$@"

exit $?
