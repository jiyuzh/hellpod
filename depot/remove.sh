#!/usr/bin/env bash

set -euo pipefail

# guard against missing arguments
if [ $# -ne 1 ]; then
	echo "remove.sh [name_of_env]"
	exit 1
fi

if [[ $EUID -ne 0 ]]; then
	echo "This script is not running as root. Try using sudo."
	exit 1
fi

SCRIPT_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"
ENV_NAME="$1"
ROOT_DIR="$(realpath -e "$SCRIPT_DIR/..")"
WORK_DIR="$SCRIPT_DIR"

sudo machinectl stop "$ENV_NAME" || true
sleep 1
sudo machinectl kill "$ENV_NAME" || true
sleep 1
sudo machinectl terminate "$ENV_NAME" || true
sleep 1
sudo machinectl remove "$ENV_NAME" || true

if [ -e "/var/lib/machines/$ENV_NAME" ]; then
	if [ "$(realpath -e "/var/lib/machines/$ENV_NAME")" = "$(realpath -e "$ROOT_DIR")" ]; then
		sudo rm -rf "/var/lib/machines/$ENV_NAME"
	else
		echo "Cannot delete '/var/lib/machines/$ENV_NAME', it is pointing to another container instance"
	fi
fi

if [ -e "/etc/systemd/nspawn/$ENV_NAME.nspawn" ]; then
	if [ "$(realpath -e "/etc/systemd/nspawn/$ENV_NAME.nspawn")" = "$(realpath -e "$WORK_DIR/$ENV_NAME.nspawn")" ]; then
		sudo rm -rf "/etc/systemd/nspawn/$ENV_NAME.nspawn"
	else
		echo "Cannot delete '/etc/systemd/nspawn/$ENV_NAME.nspawn', it is pointing to another container instance"
	fi
fi

sudo rm -rf "$ROOT_DIR"
