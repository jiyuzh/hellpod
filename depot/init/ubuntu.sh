#!/usr/bin/env bash

set -exuo pipefail

NEW_USER="test"
NEW_PASS="test"
SSH_FROM="gh:jiyuzh"

if [[ $EUID -ne 0 ]]; then
	echo "This script is not running as root. Try using sudo."
	exit 1
fi

# systemd-networkd by default is not enabled
sudo systemctl enable systemd-networkd
sudo systemctl start systemd-networkd

# ping google to test internet connection
retries=0

while ! ping -c 1 -W 1 google.com &> /dev/null; do
	retries=$((retries+1))

	if [ $retries -ge 10 ]; then
		echo "Cannot reach Internet, check your connection"
		exit 1
	fi

	sleep 1
done

if [ ! -f /etc/ssh/sshd_config ]; then

	# only keep top-level packages
	sudo apt-mark showmanual | xargs -L1 -- sh -c 'apt-cache --installed rdepends "$1" | grep -v "$1" | grep -qv "Reverse Depends:" > /dev/null && sudo apt-mark auto "$1" || true' --

	# for safety
	sudo apt-mark manual ubuntu-minimal

	# hellbomb things we don't want
	sudo apt-get --purge -y autoremove

	# enable repositories
	sudo apt-get update
	sudo apt-get install --no-install-recommends -y software-properties-common
	sudo add-apt-repository --no-update -y main
	sudo add-apt-repository --no-update -y restricted
	sudo add-apt-repository --no-update -y universe
	sudo add-apt-repository --no-update -y multiverse
	sudo apt-get update

	# setup openssh server
	sudo apt-get install --no-install-recommends -y openssh-server ssh-import-id
	sudo systemctl stop ssh || true

	# enable root login via ssh
	cat /etc/ssh/sshd_config | perl -pe 's/^\s*#?\s*PermitRootLogin\s+[-\w]+$/PermitRootLogin prohibit-password/gm' | sudo tee /etc/ssh/sshd_config > /dev/null

	# import ssh key
	ssh-import-id "$SSH_FROM"

	# autostart openssh
	sudo systemctl enable ssh
	sudo systemctl start ssh

fi

if [ ! -f "/etc/sudoers.d/$NEW_USER" ]; then

	# create normal user
	sudo adduser --disabled-password --gecos "" "$NEW_USER"
	sudo adduser "$NEW_USER" sudo
	printf "%s:%s" "$NEW_USER" "$NEW_PASS" | sudo chpasswd
	printf '%s ALL=(ALL:ALL) NOPASSWD: ALL' "$NEW_USER" | sudo tee "/etc/sudoers.d/$NEW_USER" > /dev/null

	# check everything works
	if [ "$(su "$NEW_USER" -c 'whoami')" != "$NEW_USER" ]; then
		echo "User creation failed"
		exit 1
	fi

	if [ "$(su "$NEW_USER" -c 'sudo whoami')" != "root" ]; then
		echo "User sudo failed"
		exit 1
	fi

	# import ssh key
	su "$NEW_USER" -c "ssh-import-id '$SSH_FROM'"

fi

echo "+ System configuration done"
