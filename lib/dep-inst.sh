#!/usr/bin/env false

#
# Debian/Ubuntu
#

function apt_probe
{
	builtin command -v "apt-get" &>/dev/null
}

function apt_update
{
	sudo apt-get update -y
}

function apt_install
{
	local pkg="$1"

	sudo apt-get install --no-install-recommends -y "$pkg"
}



#
# Red Hat/Fedora
#

function dnf_probe
{
	builtin command -v "dnf" &>/dev/null
}

function dnf_update
{
	sudo dnf check-update -y
}

function dnf_install
{
	local pkg="$1"

	sudo dnf install --setopt=install_weak_deps=False -y "$pkg"
}



#
# CentOS
#

function yum_probe
{
	builtin command -v "yum" &>/dev/null
}

function yum_update
{
	sudo yum check-update -y
}

function yum_install
{
	local pkg="$1"

	sudo yum install -y "$pkg" # yum do not have weak dep
}



#
# SLES/openSUSE
#

function zypper_probe
{
	builtin command -v "zypper" &>/dev/null
}

function zypper_update
{
	sudo zypper refresh -y
}

function zypper_install
{
	local pkg="$1"

	sudo zypper install --no-recommends -y "$pkg"
}



#
# Arch
#

function pacman_probe
{
	builtin command -v "pacman" &>/dev/null
}

function pacman_update
{
	sudo pacman -Syu --confirm # to arch users: you will roll your system, right?
}

function pacman_install
{
	local pkg="$1"

	sudo pacman -S --confirm "$pkg" # pacman default to strong dep only
}



#
# Gentoo
#

function emerge_probe
{
	builtin command -v "emerge" &>/dev/null
}

function emerge_update
{
	sudo emerge --sync
}

function emerge_install
{
	local pkg="$1"

	sudo emerge "$pkg" # emerge is such a beauty
}



#
# Other
#

function other_probe
{
	return 0
}

function other_update
{
	return 0
}

function other_install
{
	return 0
}
