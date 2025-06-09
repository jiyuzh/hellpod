#!/usr/bin/env bash

set -exuo pipefail

# guard against missing arguments
if [ $# -ne 1 ]; then
	echo "packer.sh [path_to_the_archive]"
	exit 1
fi

SCRIPT_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"
ROOT_DIR="$(realpath -e "$SCRIPT_DIR/..")"
WORK_DIR="$SCRIPT_DIR"
ARC_FILE="$(realpath -e "$(dirname "$1")")/$(basename "$1")"

# guard against redist packer.sh
if [ ! -f "$WORK_DIR/.superearth" ]; then
	echo "packer.sh can only run on a Hellpod machine"
	exit 1
fi

# guard against overwriting files
if [ -e "$ARC_FILE" ]; then
	echo "Output target '$ARC_FILE' already exists"
	exit 1
fi

sudo tar --acls --xattrs -cpvzf "$ARC_FILE" -C "$ROOT_DIR" .
