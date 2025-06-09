#!/usr/bin/env bash

#
# 0-prepare-env.sh
#

# guard against non-bash shells
if [ -z "$BASH_VERSION" ]; then
	echo "This script can only run with bash"
	exit 1
fi

set -exuo pipefail

# guard against missing arguments
if [ $# -ne 1 ]; then
	echo "redist.sh [name_of_env]"
	exit 1
fi

# ensure non-POSIX system binaries are there
for bin in {sudo,apt-get,chroot}; do
	if ! command -v "$bin" &>/dev/null; then
		echo "This script requires $bin to run"
		exit 1
	fi
done

sudo -v

# install things we want
apt_updated=0

function cond_install()
{
	local cmd="$1"
	local pkg="$2"

	if ! command -v "$cmd" &>/dev/null; then
		if [ $apt_updated -eq 0 ]; then
			sudo apt-get update
			apt_updated=1
		fi

		sudo apt-get install --no-install-recommends -y "$pkg"
	fi
}

# debootstrap wants these
cond_install id coreutils
cond_install wget wget
cond_install dpkg dpkg
cond_install mount mount
cond_install grep grep

# container we use
cond_install systemd-nspawn systemd-container

# network we use
cond_install virsh libvirt-clients

echo "+ Environment check passed"


#
# config.sh
#

SCRIPT_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"
ENV_NAME="$1"
ROOT_DIR="$(realpath -e "$SCRIPT_DIR/..")"
WORK_DIR="$SCRIPT_DIR"

# guard against redist redist.sh
if [ ! -f "$WORK_DIR/.superearth" ]; then
	echo "redist.sh can only run on a Hellpod machine"
	exit 1
fi


#
# 3-run-debootstrap.sh
#

# unify system configuration
if [ -f /etc/vconsole.conf ]; then
	sudo cp -f /etc/vconsole.conf "$ROOT_DIR/etc/vconsole.conf"
fi
if [ -f /etc/localtime ]; then
	sudo ln -sf "$(realpath -e /etc/localtime)" "$ROOT_DIR/etc/localtime"
fi

#
# 4-setup-machine.sh
#

# obtain virsh network interface name
bridge=$(sudo virsh net-dumpxml default | grep '<bridge ' | grep -Po "name='[^ ]+'" | cut -d"'" -f2)

# ensure virsh network is active
sudo virsh net-info default | grep Active | grep yes > /dev/null || sudo virsh net-start default

# write to nspawn file
sudo tee "$WORK_DIR/$ENV_NAME.nspawn" > /dev/null <<EOF
[EXEC]
Boot=yes
Capability=all
PrivateUsers=pick
SuppressSync=no

[FILES]
PrivateUsersOwnership=auto

[Network]
VirtualEthernet=yes
Bridge=$bridge
EOF

echo "+ Network setup done"


#
# 5-register-machine.sh
#

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
	sudo ln -s "$WORK_DIR/$ENV_NAME.nspawn" "/etc/systemd/nspawn/$ENV_NAME.nspawn"
elif [ "$(realpath -e "/etc/systemd/nspawn/$ENV_NAME.nspawn")" != "$(realpath -e "$WORK_DIR/$ENV_NAME.nspawn")" ]; then
	echo "nspawn configuration clash at '/var/lib/machines/$ENV_NAME'"
	exit 1
fi

echo "+ Machine registration done"


#
# 6-success-report.sh
#

set +x

echo
echo "+ Hellpod deployment done, enjoy your liber-tea"
echo "+ Root Folder: $ROOT_DIR"
echo "+ machinectl Handle: /var/lib/machines/$ENV_NAME"
echo "+ nspawn Config: /etc/systemd/nspawn/$ENV_NAME.nspawn"
