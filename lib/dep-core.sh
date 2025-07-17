#!/usr/bin/env false

#
# Framework
#

function dep_check
{
	local hinting=0
	local mgr="$1"
	builtin shift

	local state="bin"
	local install=0
	local failing=()

	while [[ $# -gt 0 ]]; do
		local head="$1"
		shift

		# bin1 bin2 , ...
		# bin1 bin2 = pkg1 pkg2 , ...
		# just flush out missing binaries and reset
		if [[ "$head" = "," ]]; then
			if [[ $install -eq 1 ]]; then

				# only want to print the header once
				if [[ $hinting -eq 0 ]]; then
					builtin echo "Please install the following binaries manually:"
					hinting=1
				fi

				builtin printf "    %s\n" "${failing[@]}"
			fi

			state="bin"
			install=0
			failing=()

		elif [[ "$head" = "=" ]]; then

			# bin1 bin2 = ...
			# now goto package installation attempts
			if [[ "$state" = "bin" ]]; then
				state="pkg"

			# bin1 bin2 = pkg1 pkg2 = ...
			# this is not supposed to happen
			elif [[ "$state" = "pkg" ]]; then
				builtin echo "Unexpected EOL in dependency package list"
				exit 1

			else
				builtin echo "Unexpected STATE $state in dep_check machine"
				exit 1
			fi

		else

			# bin1 bin2 ...
			# checking for binary availability
			if [[ "$state" = "bin" ]]; then

				if ! builtin command -v "$head" &>/dev/null; then
					# we have something to work for
					install=1
					failing+=("$head")
				fi

			# bin1 bin2 = pkg1 pkg2 ...
			# install package if not yet done
			elif [[ "$state" = "pkg" ]]; then

				if [[ $install -eq 1 ]]; then
					echo "Attempt to install package $head"

					if "${mgr}_install" "$head"; then
						# dependency satisified
						install=0
					fi
				fi

			else
				builtin echo "Unexpected STATE $state in dep_check machine"
				exit 1
			fi

		fi

	done

	# if hinted, then we need user action
	if [[ $hinting -eq 1 ]]; then
		exit 1
	fi
}
