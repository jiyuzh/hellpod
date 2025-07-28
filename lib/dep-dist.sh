#!/usr/bin/env false

#
# System detection
#

# Detect the distro information based on systemd standard. Return a lower-cased distro ID, or "other".
function detect_distro
{
	local OS="other"

	if [ -f /etc/os-release ]; then
		eval $(source /etc/os-release; builtin echo OS="${ID:-other}";)
	elif command -v lsb_release &>/dev/null; then
		OS=$(lsb_release -si || builtin echo "other")
	elif [ -f /etc/lsb-release ]; then
		eval $(source /etc/lsb-release; builtin echo OS="${DISTRIB_ID:-other}";)
	else
		builtin echo "Unable to determine system distro"
		exit 1
	fi

	builtin echo "${OS,,}"
}
