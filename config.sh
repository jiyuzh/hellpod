#!/usr/bin/env false

#
# User parameters
#

_SCRIPT_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"

# Name of the environment/container, from user input
ENV_NAME="$1"

# Path to the environment/container, from user input
ROOT_DIR="$(realpath -e "$2")"

# Path to the auxiliary folder for the environment/container, /a/b/env => /a/b/.env.hellpod
WORK_DIR="$(dirname "$ROOT_DIR")/.$(basename "$ROOT_DIR").hellpod"

# Distro codename to install, default to Ubuntu 24.04
DISTRO="${3:-noble}"

#
# Debootstrap parameters
#

# Git URL of Debootstrap, from Debian upstream for the latest distro supports
DEBOOTSTRAP_GIT="https://salsa.debian.org/installer-team/debootstrap.git"

# Folder to clone Debootstrap into
DEBOOTSTRAP_DIR="$WORK_DIR/debootstrap"

# Path to the Debootstrap executable
DEBOOTSTRAP_BIN="$DEBOOTSTRAP_DIR/debootstrap"

#
# Deployment parameters
#

# A file to check for the completion of Debootstrap environment install
DEPLOYMENT_CHK="$ROOT_DIR/etc/os-release"

# Initial locale of the container
DEPLOYMENT_LOCALE="en_US.UTF-8"

# Initial shell of the root inside the container
DEPLOYMENT_ROOT_SHELL="/bin/bash"

# Initial password of the root inside the container
DEPLOYMENT_ROOT_PWD="root"

# Initial location of hellpod resources inside the container
DEPLOYMENT_HELLPOD="$ROOT_DIR/.hellpod"
