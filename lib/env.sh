#!/usr/bin/env false

builtin source "$HELLPOD_DIR/lib/env-init.sh"
builtin source "$HELLPOD_DIR/lib/env-dbsp.sh"
builtin source "$HELLPOD_DIR/lib/env-work.sh"

# Setup root environment
function env_main
{
	local name="$1"
	local sys="$2"
	local dir="$3"

	extract_env "$sys" "$dir"
	configure_init "$name" "$dir"
}

