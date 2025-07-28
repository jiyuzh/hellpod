#!/usr/bin/env false

builtin source "$HELLPOD_DIR/lib/dep-inst.sh"
builtin source "$HELLPOD_DIR/lib/dep-core.sh"
builtin source "$HELLPOD_DIR/lib/dep-list.sh"
builtin source "$HELLPOD_DIR/lib/dep-dist.sh"

# Setup software dependencies
function prep_dep
{
	local distro="$(detect_distro)"

	if [[ $(builtin type -t "${distro}_prep") == function ]]; then
		"${distro}_prep"
	else
		other_prep
	fi
}
