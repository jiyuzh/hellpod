#!/usr/bin/env false

#
# List of initialization routines for init systems
#

function systemd_init_prep
{
	local name="$1"
	local dir="$2"

	builtin echo "Configuring systemd-based installation..."

	# run systemd initialization for systemd
	sudo systemd-firstboot --root="$dir" --reset

	# root-shell and locale affects execution outcome so they are statically defined
	# root-password is predefined to a well known value so user can change it later
	# keymap and timezone is copied for user convenience
	# machine-id needs to be unique and random for networking and manageability
	sudo systemd-firstboot --root="$dir" \
		--hostname="$name" \
		--root-shell="/bin/bash" \
		--locale="en_US.UTF-8" \
		--root-password="root" \
		--copy-keymap \
		--copy-timezone \
		--setup-machine-id \
		--force \
	;
}

function other_init_prep
{
	builtin echo "Cannot detect init system type. Please do manual configuration."
}
