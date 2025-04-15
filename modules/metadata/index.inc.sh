# shellcheck shell=bash
# shellcheck disable=SC2154

PAPYRUS_PANDOC_FLAGS+=("--metadata-file=$preprocessed_md_file.json")
PAPYRUS_YPP_FLAGS+=(-l "$__MODULE_ROOT__/index.lua")
