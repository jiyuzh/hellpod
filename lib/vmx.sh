#!/usr/bin/env false

builtin source "$HELLPOD_DIR/lib/vmx-net.sh"
builtin source "$HELLPOD_DIR/lib/vmx-reg.sh"

# Setup virtualization framework
function vmx_main
{
	local name="$1"
	local sys="$2"
	local dir="$3"

	vmx_reg_nspawn "$name" "$dir"
	vmx_reg_machinectl "$name" "$dir"
	vmx_config_net "$name" "$dir"
}

