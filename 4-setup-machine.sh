#!/usr/bin/env bash

set -exuo pipefail

SCRIPT_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"
source "$SCRIPT_DIR/config.sh"

if [ ! -f "$WORK_DIR/$ENV_NAME.nspawn" ]; then

	# obtain virsh network interface name
	bridge=$(sudo virsh net-dumpxml default | grep '<bridge ' | grep -Po "name='[^ ]+'" | cut -d"'" -f2)

	# ensure virsh network is active
	sudo virsh net-info default | grep Active | grep yes > /dev/null || sudo virsh net-start default

	# write to nspawn file
	sudo tee "$WORK_DIR/$ENV_NAME.nspawn" > /dev/null <<EOF
[Exec]
Boot=yes
Capability=all
PrivateUsers=pick
SuppressSync=no

[Files]
PrivateUsersOwnership=auto

[Network]
VirtualEthernet=yes
Bridge=$bridge
EOF

	# enable systemd-networkd, if available
	sudo systemd-nspawn -D "$ROOT_DIR" /usr/bin/env bash -c 'systemctl enable systemd-networkd || true'

fi

echo "+ Network setup done"
