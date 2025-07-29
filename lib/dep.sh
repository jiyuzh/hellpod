#!/usr/bin/env false

builtin source "$HELLPOD_DIR/lib/dep-inst.sh"
builtin source "$HELLPOD_DIR/lib/dep-core.sh"
builtin source "$HELLPOD_DIR/lib/dep-list.sh"
builtin source "$HELLPOD_DIR/lib/dep-dist.sh"

# Setup software dependencies
function dep_main
{
	local distro="$(detect_distro)"

	if [[ $(builtin type -t "${distro}_dist_prep") == function ]]; then
		"${distro}_dist_prep"
	else
		other_dist_prep
	fi
}
