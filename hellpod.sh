#!/usr/bin/env bash

#
# Guard against non-bash shells
#

if [[ -z "$BASH_VERSION" ]]; then
	builtin echo "This script can only run with bash"
	exit 1
fi

set -euo pipefail

#
# Guard against missing arguments
#

if [[ $# -lt 2 ]]; then
	builtin echo "hellpod.sh [name_of_env] [path_of_env] [[distro_of_env]] [[--]] [[args_for_gbc]]"
	exit 1
fi

#
# Ensure genesis binaries are there
#

for bin in {sudo,dirname,realpath}; do
	if ! builtin command -v "$bin" &>/dev/null; then
		builtin echo "This script requires '$bin' to run"
		exit 1
	fi
done

#
# Check if we can do our job
#

sudo -v

#
# Parse arguments
#

# must-haves
ENV_NAME="$1"
shift

ENV_PATH=$(realpath -m "$1")
shift

# distro by default is Ubuntu 24.04 LTS
ENV_DIST="noble"

# if not terminated, use user-specified distro
if [[ $# -ge 1 ]] && [[ "$1" != "--" ]]; then
	ENV_DIST="$1"
	shift
fi

# eat the seperator
if [[ $# -ge 1 ]] && [[ "$1" = "--" ]]; then
	shift
fi

# $@ now contains parameters for gbc

#
# Start of actual jobs
#

HELLPOD_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"

builtin source "$HELLPOD_DIR/lib/dep.sh"
builtin source "$HELLPOD_DIR/lib/env.sh"
builtin source "$HELLPOD_DIR/lib/vmx.sh"

# dep_main
# env_main "$ENV_NAME" "$ENV_DIST" "$ENV_PATH"
vmx_main "$ENV_NAME" "$ENV_DIST" "$ENV_PATH"

echo "Done"
