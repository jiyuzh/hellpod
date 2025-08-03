#!/usr/bin/env false

#
# List of dependencies for distros
#

function ubuntu_dist_prep
{
	if ! apt_probe; then
		builtin echo "Failed to find system package manager 'apt'"

		other_dist_prep
		return 0
	fi

	dep_check apt binary \
		arch dd dirname env ln ls mkdir realpath test = coreutils , \
		bash = bash , \
		dpkg dpkg-deb = dpkg , \
		git = git , \
		grep = grep , \
		sudo = sudo , \
		machinectl systemd-nspawn = systemd-container , \
		networkctl systemd-firstboot = systemd , \
		debootstrap = debootstrap , \
	;
}

# Prep function for all other distros, this function must present
function other_dist_prep
{
	dep_check other binary \
		systemd-firstboot systemd-nspawn virsh git debootstrap , \
	;
}
