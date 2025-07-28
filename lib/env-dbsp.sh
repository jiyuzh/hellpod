#!/usr/bin/env false

DEBOOTSTRAP_GIT="https://salsa.debian.org/installer-team/debootstrap.git"

function check_debootstrap
{
	local dir="$1"

	if [[ -f "$dir/debootstrap" ]] && [[ -x "$dir/debootstrap" ]]; then
		if "$dir/debootstrap" --help | grep -q "Bootstrap a Debian base system into a target directory."; then
			return 0
		fi
	fi

	return 1
}

function get_debootstrap
{
	local dir="$1"

	# path exists
	if [[ -e "$dir" ]]; then
		if check_debootstrap; then
			return 0
		else
			builtin echo "Cannot obtain latest debootstrap: Path '$dir' is occupied"
			exit 1
		fi
	else
		mkdir -p "$(dirname "$dir")"

		git clone --depth 1 "$DEBOOTSTRAP_GIT" "$dir"

		if ! check_debootstrap; then
			builtin echo "Validation of debootstrap failed: Git '$DEBOOTSTRAP_GIT' cannot provide the right binary"
			exit 1
		fi
	fi
}

function run_debootstrap
{
	local dir="$1"
	shift

	get_debootstrap "$dir"

	# arch shall be explicitly defined, 
	sudo env DEBOOTSTRAP_DIR="$dir" "$dir/debootstrap" --arch=$(dpkg --print-architecture) "$@"
}
