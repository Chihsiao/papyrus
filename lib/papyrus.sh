#!/usr/bin/env bash

set -euo pipefail

#region paths
##region PAPYRUS_CONF
if ! [ -v PAPYRUS_CONF ]; then
    PAPYRUS_CONF="${1:?no configuration}"
    shift
fi

PAPYRUS_CONF="$(realpath -mL -- "$PAPYRUS_CONF")"
readonly PAPYRUS_CONF
##endregion

##region PAPYRUS_ROOT
: "${PAPYRUS_ROOT:=$(dirname "$PAPYRUS_CONF")}"
PAPYRUS_ROOT="$(realpath -mL -- "$PAPYRUS_ROOT")"
readonly PAPYRUS_ROOT
##endregion

: "${PAPYRUS_BASENAME:=$(basename "$PAPYRUS_CONF" .papyrus)}"

: "${PAPYRUS_SRC:=src/$PAPYRUS_BASENAME}"
: "${PAPYRUS_SRC_INDEX_NAME:=index.md}"

: "${PAPYRUS_TARGET:=target}"
: "${PAPYRUS_TARGET_BUNDLE_NAME:=$PAPYRUS_BASENAME.docx}"
: "${PAPYRUS_TARGET_PREPROCESSED_NAME:=$PAPYRUS_BASENAME/preprocessed.md}"

function absolute_path_of() {
    local filename="${1:?no filename}"
    if [ "${filename:0:1}" = '/' ]; then printf '%s\n' "$filename";
        else realpath -mL -- "${2:-$PAPYRUS_ROOT}/$filename"; fi
}

function path_resolve() {
    src_dir="$(absolute_path_of "$PAPYRUS_SRC")"
    index_md_file="$src_dir/$PAPYRUS_SRC_INDEX_NAME"

    target_dir="$(absolute_path_of "$PAPYRUS_TARGET")"
    bundle_file="$target_dir/$PAPYRUS_TARGET_BUNDLE_NAME"
    preprocessed_md_file="$target_dir/$PAPYRUS_TARGET_PREPROCESSED_NAME"
}

path_resolve
#endregion

PAPYRUS_YPP_FLAGS=()
PAPYRUS_PANDOC_FLAGS=()

#region modules
: "${PAPYRUS_MODULES:=modules}"

function import_module() {
    local __MODULE_NAME__ \
          __MODULE_ROOT__ \
          __FILE__

    for __MODULE_NAME__ in "$@"
    do
        __MODULE_ROOT__="$PAPYRUS_MODULES/$__MODULE_NAME__"
        __FILE__="$__MODULE_ROOT__/index.inc.sh"
        if [ -f "$__FILE__" ]
        then
            # shellcheck source=/dev/null
            source "$__FILE__"
            return
        fi

        __FILE__="$__MODULE_ROOT__/index.lua"
        if [ -f "$__FILE__" ]
        then
            PAPYRUS_YPP_FLAGS+=(-l "$__FILE__")
            return
        fi

        __FILE__="$__MODULE_ROOT__.lua"
        if [ -f "$__FILE__" ]
        then
            PAPYRUS_YPP_FLAGS+=(-l "$__FILE__")
            return
        fi
    done
}

import_module builtins
#endregion

# shellcheck source=/dev/null
source "$PAPYRUS_CONF"

#region operations
function preprocess() {
    "${YPP:-ypp}" -o "$preprocessed_md_file" \
        "${PAPYRUS_YPP_FLAGS[@]}" -- \
        "$index_md_file"
}

function compile_bundle() {
    [ "${1:-}" = 'dont_preprocess' ] || preprocess
    "${PANDOC:-pandoc}" --embed-resources --standalone --output="$bundle_file" \
        --from=markdown --resource-path="$src_dir" \
        "${PAPYRUS_PANDOC_FLAGS[@]}" -- \
        "$preprocessed_md_file"
}

function open_bundle() {
    setsid xdg-open "$bundle_file"
}

function clean() {
    rm -rf "$target_dir"
}
#endregion

"$@"
