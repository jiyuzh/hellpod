#!/usr/bin/env bash

# find and run all bash files in the form of 1-something.sh in alphabetical order

# valid names & ordering rule:
# 1-exe
# 1.1-exe.sh
# 1.2-exe.pl
# 2-exe
# 3-exe
# 3.1-exe
#
# invalid names:
# exe
# 1-exe.bak
# 1-exe.old
# 1-exe.inc.sh
#
# not recommended names:
# 1-1-exe
# 1-1exe

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath -e "${BASH_SOURCE[0]:-$0}")")"

delim="$(printf '\1\1\4\5\1\4 i_am_xargs_substitution_cookie_why_you_want_to_use_this_as_your_arg? \1\9\1\9\8\10')"

find "$SCRIPT_DIR" -maxdepth 1 -type f -executable -print0 | `# find all executable files` \
grep -zP '\/\d+(?:\.\d+)*-(?:(?!\.(?:bak|old|inc\.\w+)$)[^\/])*$' | `# verify the file names starts with 1- or 1.1- and is not a .bak, .old, .inc.*` \
sort -z -t '-' -V | `# sort like version number (means 1.6 < 1.11) for ordered execution` \
xargs -r0 -I "$delim" -- sh -c '"$@" || exit 255' -- "$delim" "$@" `# run each binary with argument passthrough`
