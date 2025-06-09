#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"
source "$SCRIPT_DIR/config.sh"

echo
echo "+ Hellpod deployment done, enjoy your liber-tea"
echo "+ Root Folder: $ROOT_DIR"
echo "+ machinectl Handle: /var/lib/machines/$ENV_NAME"
echo "+ nspawn Config: /etc/systemd/nspawn/$ENV_NAME.nspawn"
