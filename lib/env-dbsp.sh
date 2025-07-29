#!/usr/bin/env false

DEBOOTSTRAP_GIT="${DEBOOTSTRAP_GIT:-"https://salsa.debian.org/installer-team/debootstrap.git"}"

# Check if the debootstrap installation is valid
function check_debootstrap
{
	local dir="$1"

	if [[ -f "$dir/debootstrap" ]] && [[ -x "$dir/debootstrap" ]]; then

		# use true here as grep -q will terminate on first match and leave a broken pipe
		if ("$dir/debootstrap" --help || builtin true) | grep -q "Bootstrap a Debian base system into a target directory."; then
			return 0
		fi
	fi

	return 1
}

# Obtain the latest debootstrap from a predefined git repo
function get_debootstrap
{
	local dir="$1"

	# path exists
	if [[ -e "$dir" ]]; then

		# check for validity first
		if check_debootstrap "$dir"; then
			return 0

		# let go empty folder and alert all others
		elif [[ ! -d "$dir" ]] || [[ -n "$(ls -A "$dir")" ]]; then
			builtin echo "Cannot obtain latest debootstrap: Path '$dir' is occupied"
			exit 1
		fi
	fi

	mkdir -p "$(dirname "$dir")"

	git clone --depth 1 "$DEBOOTSTRAP_GIT" "$dir"

	if ! check_debootstrap "$dir"; then
		builtin echo "Validation of debootstrap failed: Git '$DEBOOTSTRAP_GIT' cannot provide the right binary"
		exit 1
	fi
}

# Wrapper function for executing debootstrap
function run_debootstrap
{
	local dir="$1"
	local sys="$2"
	local env="$3"

	get_debootstrap "$dir"

	# --arch shall be explicitly defined for non-deb systems, as per Fedora docunment
	# --keep-debootstrap-dir is semi-undocumented (in changelog only), it allows us to work in a non-empty folder
	sudo env DEBOOTSTRAP_DIR="$dir" "$dir/debootstrap" --arch=$(dpkg --print-architecture) --keep-debootstrap-dir "$sys" "$env"

	# migrate the generated debootstrap execution snapshot files (due to --keep-debootstrap-dir)
	sudo mv -T "$env/debootstrap/" "$dir/debootstrap.conf/"
}
