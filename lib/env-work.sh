#!/usr/bin/env false

# Extract the root file hierarchy. No initialization is done.
function extract_env
{
	local sys="$1"
	local dir="$2"

	mkdir -p "$dir"

	# ensure the target is a directory
	if [[ ! -d "$dir" ]]; then
		builtin echo "Target path '$dir' is not a directory"
		exit 1
	fi

	# as run_debootstrap masked empty folder check, we need to do it here explicitly
	if [[ -n "$(ls -A "$dir")" ]]; then
		builtin echo "Target folder '$dir' is not empty"
		exit 1
	fi

	run_debootstrap "$dir/.hellpod/debootstrap" "$sys" "$dir"
}

# Detect the init system type of the root file hierarchy.
function detect_init
{
	# detect systemd
	if [[ -f "$dir/sbin/init" ]] && [[ -f "$dir/lib/systemd/systemd" ]]; then
		if [[ "$(realpath -e "$dir/sbin/init" 2>&1)" = "$(realpath -e "$dir/lib/systemd/systemd" 2>&1)" ]]; then
			echo "systemd"
			return 0
		fi
	fi

	echo "other"
}

# Configure the environment configuration values
function configure_init
{
	local initsys="$(detect_init)"
	local name="$1"
	local dir="$2"

	if [[ $(builtin type -t "${initsys}_init_prep") == function ]]; then
		"${initsys}_init_prep" "$name" "$dir"
	else
		other_init_prep "$name" "$dir"
	fi
}
