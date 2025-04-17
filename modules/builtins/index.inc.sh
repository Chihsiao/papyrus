# shellcheck shell=bash
# shellcheck disable=SC2154,SC1091

PAPYRUS_YPP_FLAGS+=(-l "$__MODULE_ROOT__/utils.lua")

source "$__MODULE_ROOT__/metadata.inc.sh"
source "$__MODULE_ROOT__/refdoc.inc.sh"
