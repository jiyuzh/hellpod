#!/usr/bin/env false

#
# List of dependencies for distros
#

function ubuntu_prep
{
	if ! apt_probe; then
		builtin echo "Failed to find system package manager 'apt'"

		other_prep
		return 0
	fi

	dep_check apt binary \
		arch dirname env mkdir = coreutils , \
		dpkg dpkg-deb = dpkg , \
		git = git , \
		grep = grep , \
		machinectl systemd-nspawn = systemd-container , \
		networkctl systemd-firstboot = systemd , \
		debootstrap = debootstrap , \
		sl = wget , \
	;
}

# Prep function for all other distros, this function must present
function other_prep
{
	dep_check other binary \
		systemd-firstboot systemd-nspawn virsh git debootstrap , \
	;
}
