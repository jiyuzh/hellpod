#!/usr/bin/env bash

set -exuo pipefail

SCRIPT_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"
source "$SCRIPT_DIR/config.sh"

# check if debootstrap is already there
if [ ! -d "$DEBOOTSTRAP_DIR" ] || [ ! -f "$DEBOOTSTRAP_DIR/debootstrap" ]|| [ ! -x "$DEBOOTSTRAP_DIR/debootstrap" ]; then
	# remove and recreate with a bit of caution
	if [ -e "$DEBOOTSTRAP_DIR" ]; then
		if [[ "$DEBOOTSTRAP_DIR" = *.hellpod/* ]]; then
			sudo rm -rf "$DEBOOTSTRAP_DIR" || true
		else
			echo "Debootstrap directory '$DEBOOTSTRAP_DIR' exists and should be removed"
			exit 1
		fi
	fi

	git clone --depth 1 "$DEBOOTSTRAP_GIT" "$DEBOOTSTRAP_DIR"
fi

echo "+ Debootstrap download done"

