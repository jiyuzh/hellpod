#!/usr/bin/env bash

set -exuo pipefail

SCRIPT_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"
source "$SCRIPT_DIR/config.sh"

# self-containize hellpod
if [ ! -d "$DEPLOYMENT_HELLPOD" ]; then
	mv "$WORK_DIR" "$DEPLOYMENT_HELLPOD"
	cp -r "$SCRIPT_DIR/depot"/* "$DEPLOYMENT_HELLPOD/"
elif [ ! -f "$DEPLOYMENT_HELLPOD/.superearth" ]; then
	echo "Name clash at '$DEPLOYMENT_HELLPOD' folder"
	exit 1
fi

# register the container for machinectl
if [ ! -e "/var/lib/machines/$ENV_NAME" ]; then
	sudo mkdir -p /var/lib/machines
	sudo ln -s "$ROOT_DIR" "/var/lib/machines/$ENV_NAME"
elif [ "$(realpath -e "/var/lib/machines/$ENV_NAME")" != "$(realpath -e "$ROOT_DIR")" ]; then
	echo "machinectl handle clash at '/var/lib/machines/$ENV_NAME'"
	exit 1
fi

# register the configuration for nspawn
if [ ! -e "/etc/systemd/nspawn/$ENV_NAME.nspawn" ]; then
	sudo mkdir -p "/etc/systemd/nspawn/"
	sudo ln -s "$DEPLOYMENT_HELLPOD/$ENV_NAME.nspawn" "/etc/systemd/nspawn/$ENV_NAME.nspawn"
elif [ "$(realpath -e "/etc/systemd/nspawn/$ENV_NAME.nspawn")" != "$(realpath -e "$DEPLOYMENT_HELLPOD/$ENV_NAME.nspawn")" ]; then
	echo "nspawn configuration clash at '/var/lib/machines/$ENV_NAME'"
	exit 1
fi

echo "+ Machine registration done"
