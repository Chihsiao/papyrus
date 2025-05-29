# shellcheck shell=bash
# shellcheck disable=SC2154

PAPYRUS_YPP_FLAGS+=(-l "$__MODULE_ROOT__/lua/metadata.lua")
PAPYRUS_INITIALIZERS+=(__builtins_metadata_setup)
function __builtins_metadata_setup() {
    PAPYRUS_PANDOC_FLAGS+=(--metadata-file="$preprocessed_md_file.json")
}
