# shellcheck shell=bash

import_module asset_resolvers

PAPYRUS_YPP_FLAGS+=(
    -l "$__MODULE_ROOT__/index.lua"
)
