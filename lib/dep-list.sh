#!/usr/bin/env false

function ubuntu_prep
{
	if ! apt_probe; then
		builtin echo "Failed to find system package manager 'apt'"

		other_prep
		return 0
	fi

	dep_check apt \
		git = git , \
		systemd-nspawn = systemd-container systemd , \
		systemd-firstboot = systemd , \
		virsh = libvirt-clients , \
		debootstrap = debootstrap , \
	;
}

function other_prep
{
	dep_check other \
		systemd-firstboot systemd-nspawn virsh , \
	;
}
