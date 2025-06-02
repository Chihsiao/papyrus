# shellcheck shell=bash
# shellcheck disable=SC2154

[[ ! -v "MMDC_SEARCH_PATH" ]] || return 0

export MMDC_SEARCH_PATH="$PATH"
export PATH="$__MODULE_ROOT__:$PATH"
