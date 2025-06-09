#!/usr/bin/env bash

set -exuo pipefail

# hellpod.sh [name_of_env] [path_of_env] [[distro_of_env]]
ROOT_INPUT="$2"

# let's create the dir first
mkdir -p "$ROOT_INPUT"

# since the dir must exists now, we can normalize the path
ROOT_DIR="$(realpath -e "$ROOT_INPUT")"

# do this once more for our working dir
# for root 'grand/parent/dir', the working dir should be 'grand/parent/.dir.hellpod'
# any change to this input shall also change ./config.sh
WORK_INPUT="$(dirname "$ROOT_DIR")/.$(basename "$ROOT_DIR").hellpod"
mkdir -p "$WORK_INPUT"
WORK_DIR="$(realpath -e "$WORK_INPUT")"

# now we can run config.sh which uses realpath -e
SCRIPT_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"
source "$SCRIPT_DIR/config.sh"

# debootstrap wants an empty folder
if [ ! -d "$ROOT_DIR" ] || [ -n "$(ls -A "$ROOT_DIR")" ]; then
	# ... or an existing setup, same as DEPLOYMENT_CHK config
	if [ ! -f "$DEPLOYMENT_CHK" ]; then
		echo "Target directory '$ROOT_DIR' is not empty and it would be wiped"
		exit 1
	fi
fi

# working directory can be either empty ...
if [ ! -d "$WORK_DIR" ] || [ -n "$(ls -A "$WORK_DIR")" ]; then
	# ... or our home
	if [ ! -f "$WORK_DIR/.superearth" ]; then
		echo "Working directory '$WORK_DIR' is not empty and it would be wiped"
		exit 1
	fi
fi

# spread managed democracy
touch "$WORK_DIR/.superearth"

# check for name conflict
if [ -e "/var/lib/machines/$ENV_NAME" ]; then
	echo "Environment '$ENV_NAME' already exists"
	rm -rf "$WORK_DIR"
	exit 1
fi

echo "+ Working directories created"
