#!/usr/bin/env false

# Register the config file for nspawn
function vmx_reg_nspawn
{
	local name="$1"
	local dir="$2"

	sudo mkdir -p "/etc/systemd/nspawn/"

	if sudo test ! -e "/etc/systemd/nspawn/$name.nspawn"; then

		sudo dd status=none of="/etc/systemd/nspawn/$name.nspawn" << EOF
[Exec]
Boot=yes
Capability=all
PrivateUsers=pick
SuppressSync=no

[Files]
PrivateUsersOwnership=auto

[Network]
Private=yes
VirtualEthernet=yes
EOF

	sudo ln -Pfn "/etc/systemd/nspawn/$name.nspawn" "$dir/.hellpod/$name.nspawn"

	else
		echo "nspawn configuration clash at '/etc/systemd/nspawn/$name.nspawn'"
		exit 1
	fi
}

# Register the container for machinectl
function vmx_reg_machinectl
{
	local name="$1"
	local dir="$2"

	sudo mkdir -p /var/lib/machines

	if sudo test ! -e "/var/lib/machines/$name"; then
		sudo ln -sn "$dir" "/var/lib/machines/$name"
	elif [[ "$(sudo realpath -e "/var/lib/machines/$name")" != "$(sudo realpath -e "$dir")" ]]; then
		echo "machinectl handle clash at '/var/lib/machines/$name'"
		exit 1
	fi
}
