#!/usr/bin/env false

#
# Framework
#

function dep_check_core
{
	local action_stage="$1"
	builtin shift

	local package_manager="$1"
	builtin shift

	local checking_type="$1"
	builtin shift

	# persistent states
	local header_printed=0
	local manager_updated=0

	# resetting states
	local current_state="__check__"
	local pending_install=0
	local failed_targets=()

	while [[ $# -gt 0 ]]; do
		local this_token="$1"
		shift

		# bin1 bin2 , ...
		# bin1 bin2 = pkg1 pkg2 , ...
		# just flush out missing binaries and reset
		if [[ "$this_token" = "," ]]; then
			if [[ $pending_install -eq 1 ]]; then

				# only want to print the header once
				if [[ $header_printed -eq 0 ]]; then
					builtin echo "Please provide the following $checking_type manually:"
					header_printed=1
				fi

				builtin printf "    %s\n" "${failed_targets[@]}"
			fi

			current_state="__check__"
			pending_install=0
			failed_targets=()

		elif [[ "$this_token" = "=" ]]; then

			# bin1 bin2 = ...
			# now goto package installation attempts
			if [[ "$current_state" = "__check__" ]]; then
				current_state="__repair__"

			# bin1 bin2 = pkg1 pkg2 = ...
			# this is not supposed to happen
			elif [[ "$current_state" = "__repair__" ]]; then
				builtin echo "Unexpected token '=' in dependency package list"
				exit 1

			else
				builtin echo "Unexpected STATE $current_state in dep_check machine"
				exit 1
			fi

		else

			# bin1 bin2 ...
			# checking for binary availability
			if [[ "$current_state" = "__check__" ]]; then

				if [[ "$checking_type" = "binary" ]]; then
					if ! builtin command -v "$this_token" &>/dev/null; then
						# we have something to work for
						pending_install=1
						failed_targets+=("$this_token")
					fi

				elif [[ "$checking_type" = "file" ]]; then
					if [[ ! -f "$this_token" ]]; then
						# we have something to work for
						pending_install=1
						failed_targets+=("$this_token")
					fi

				else
					builtin echo "Unexpected MODE $checking_type in dep_check machine"
					exit 1
				fi

			# bin1 bin2 = pkg1 pkg2 ...
			# install package if not yet done
			elif [[ "$current_state" = "__repair__" ]]; then

				if [[ "$action_stage" = "__try__" ]]; then
					if [[ $pending_install -eq 1 ]]; then
						builtin echo "=== BEGIN package manager output for installing $this_token ==="

						# refresh repositories if first time
						if [[ $manager_updated -eq 0 ]]; then
							"${package_manager}_update"
							manager_updated=1
						fi

						# perform install and fallback
						if "${package_manager}_install" "$this_token"; then
							# dependency satisified
							pending_install=0
						fi

						builtin echo "=== END package manager output for installing $this_token ==="
						builtin echo ""
					fi

				elif [[ "$action_stage" = "__catch__" ]]; then
					: # do nothing
				else
					builtin echo "Unexpected STAGE $action_stage in dep_check machine"
					exit 1
				fi

			else
				builtin echo "Unexpected STATE $current_state in dep_check machine"
				exit 1
			fi

		fi

	done

	# if header printed, then we have some issue for the user to handle
	if [[ $header_printed -eq 1 ]]; then
		exit 1
	fi
}

# Check for binary dependencies and perform install when necessary.
#
# Syntax:
#   dep_check $mgr $mode ( $bin ($bin)* '=' $pkg ($pkg)* ',' )+
#
# Parameters:
#   $mgr : The package manager to invoke, require to provide:
#     ${mgr}_update : Run once before first install
#     ${mgr}_install : Run for each missing package
#   $mode : Select the dependency detection mode, can be either 'binary' or 'file'.
#   $bin : The binary/file(s) that need to present. Any missing one will trigger the installation process.
#   $pkg : The package(s) that provides listed binary/file(s). Any successfully installed one will conclude the installation process.
#
# Example:
#   dep_check apt bin \
#     git = git , \
#     systemd-nspawn = systemd-container systemd , \
#     systemd-firstboot = systemd , \
#     virsh = libvirt-clients libvirt-daemon , \
#     debootstrap = debootstrap , \
#   ;
function dep_check
{
	dep_check_core __try__ "$@"
	dep_check_core __catch__ "$@"
}
