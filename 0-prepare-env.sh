#!/usr/bin/env bash

# guard against non-bash shells
if [ -z "$BASH_VERSION" ]; then
	echo "This script can only run with bash"
	exit 1
fi

set -exuo pipefail

# guard against missing arguments
if [ $# -lt 2 ] && [ $# -gt 3 ]; then
	echo "hellpod.sh [name_of_env] [path_of_env] [[distro_of_env]]"
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

# clone various repo
cond_install git git

# debootstrap wants these
cond_install id coreutils
cond_install wget wget
cond_install dpkg dpkg
cond_install mount mount
cond_install grep grep

# container we use
cond_install systemd-firstboot systemd
cond_install systemd-nspawn systemd-container

# network we use
cond_install virsh libvirt-daemon

echo "+ Environment check passed"
