#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"
source "$SCRIPT_DIR/config.sh"

# check if debootstrap is already there
if [ ! -d "$DEBOOTSTRAP_DIR" ] || [ ! -f "$DEBOOTSTRAP_BIN" ] || [ ! -x "$DEBOOTSTRAP_BIN" ]; then
	echo "Debootstrap directory '$DEBOOTSTRAP_DIR' exists but is invalid"
	exit 1
fi

# check if environment is already there
if [ ! -d "$ROOT_DIR" ] || [ -n "$(ls -A "$ROOT_DIR")" ]; then
	if [ ! -f "$DEPLOYMENT_CHK" ]; then
		echo "Environment directory '$ROOT_DIR' exists but is invalid"
		exit 1
	fi
else
	# debootstrap needs DEBOOTSTRAP_DIR to search for itself
	sudo env DEBOOTSTRAP_DIR="$DEBOOTSTRAP_DIR" "$DEBOOTSTRAP_BIN" --arch amd64 "$DISTRO" "$ROOT_DIR"

	# unify system configuration
	sudo systemd-firstboot --root="$ROOT_DIR" --reset
	sudo systemd-firstboot --root="$ROOT_DIR" --hostname="$ENV_NAME" --locale="$DEPLOYMENT_LOCALE" --root-shell="$DEPLOYMENT_ROOT_SHELL" --root-password="$DEPLOYMENT_ROOT_PWD" --setup-machine-id --copy-keymap --copy-timezone --force
fi

echo "+ Debootstrap deployment done"
