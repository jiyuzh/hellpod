#!/usr/bin/env bash

# guard against non-bash shells
if [[ -z "$BASH_VERSION" ]]; then
	builtin echo "This script can only run with bash"
	exit 1
fi

set -euo pipefail

# guard against missing arguments
if [[ $# -lt 2 ]]; then
	builtin echo "hellpod.sh [name_of_env] [path_of_env] [[distro_of_env]] [[--]] [[args_for_gbc]]"
	exit 1
fi

# ensure genesis binaries are there
for bin in {sudo,dirname,realpath}; do
	if ! builtin command -v "$bin" &>/dev/null; then
		builtin echo "This script requires '$bin' to run"
		exit 1
	fi
done

sudo -v

HELLPOD_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"

builtin source "$HELLPOD_DIR/lib/dep.sh"
