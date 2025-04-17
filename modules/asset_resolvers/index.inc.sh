# shellcheck shell=bash
# shellcheck disable=SC2154

PAPYRUS_YPP_FLAGS+=(
    -l "$__MODULE_ROOT__/index.lua"
    -l "$__MODULE_ROOT__/resolvers/md_figures.lua"
    -l "$__MODULE_ROOT__/resolvers/md_figures/mermaid.lua"
)
