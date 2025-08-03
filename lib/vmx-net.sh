#!/usr/bin/env false

# Oh hell. Networking is so complex
function vmx_config_net
{
	local name="$1"
	local dir="$2"

	sudo mkdir -p "/usr/lib/systemd/network/"

	if sudo test ! -e "/usr/lib/systemd/network/50-ve-$name.network"; then

		sudo dd status=none of="/usr/lib/systemd/network/50-ve-$name.network" << EOF
[Match]
Name=ve-$name
Driver=veth

[Network]
Address=10.20.30.40/24
LinkLocalAddressing=yes
DHCPServer=yes
IPMasquerade=both
LLDP=yes
EmitLLDP=customer-bridge
IPv6AcceptRA=no
IPv6SendRA=yes

EOF

	sudo ln -Pfn "/usr/lib/systemd/network/50-ve-$name.network" "$dir/.hellpod/ve-$name.network"

	else
		echo "systemd-networkd handle clash at '/usr/lib/systemd/network/50-ve-$name.network'"
		exit 1
	fi

	sudo networkctl reload
}
