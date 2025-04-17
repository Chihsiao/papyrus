#!/usr/bin/env bash

set -euo pipefail

function use_default() {
    for assignment in "$@"; do
        local var def_val var_set_empty=

        var="${assignment%%=*}"
        def_val="${assignment#*=}"

        if [[ "${var:(-1):1}" = ':' ]]; then
            var="${var::(-1)}"
            var_set_empty=1
        fi

        local var_def="$var"_def

        # assert
        # || $var is unset
        # || $var is set and default
        # || $var is set and non-default and non-empty
        # || $var is set and non-default and empty and to-set-when-empty

        [[ ! -v "$var" \
        || ( -v "$var_def" && "${!var}" = "${!var_def}" ) \
        || -n "${!var}" || -n "$var_set_empty" \
        ]] || continue

        # assert
        # || $def_val is non-empty
        # || $def_val is empty and emptiable
        [[ -n "$def_val" || -n "${def_val_emptiable-1}" ]] || continue

        export -- "$var_def=$def_val"
        export -- "$var=$def_val"
    done
}

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

use_default \
    PAPYRUS_BASENAME:="$(basename "$PAPYRUS_CONF" .papyrus)" \
    \
    PAPYRUS_SRC:=src \
    PAPYRUS_SRC_INDEX_NAME=index.md \
    \
    PAPYRUS_TARGET:=target \
    PAPYRUS_TARGET_BUNDLE_FORMAT:=docx \
    PAPYRUS_TARGET_PREPROCESSED_NAME:=preprocessed.md \
    ;

function absolute_path_of() {
    local filename="${1:?no filename}"
    if [ "${filename:0:1}" = '/' ]; then printf '%s\n' "$filename";
        else realpath -mL -- "${2:-$PAPYRUS_ROOT}/$filename"; fi
}
#endregion

PAPYRUS_YPP_FLAGS=()
PAPYRUS_PANDOC_FLAGS=()
PAPYRUS_INITIALIZERS=(
    path_resolve
)

#region modules
use_default PAPYRUS_MODULES:=modules

function import_module() {
    local __MODULE_NAME__ \
          __MODULE_ROOT__ \
          __FILE__

    for __MODULE_NAME__ in "$@"
    do
        local k="__MODULE_IMPORTED_${__MODULE_NAME__}__"
        # assert module is not imported
        [[ ! -v "$k" ]] || continue

        __MODULE_ROOT__="$PAPYRUS_MODULES/$__MODULE_NAME__"
        __FILE__="$__MODULE_ROOT__/index.inc.sh"
        if [ -f "$__FILE__" ]
        then
            # shellcheck source=/dev/null
            source "$__FILE__"
            export -- "$k"=1
            continue
        fi

        __FILE__="$__MODULE_ROOT__/index.lua"
        if [ -f "$__FILE__" ]
        then
            PAPYRUS_YPP_FLAGS+=(-l "$__FILE__")
            export -- "$k"=1
            continue
        fi

        __FILE__="$__MODULE_ROOT__.lua"
        if [ -f "$__FILE__" ]
        then
            PAPYRUS_YPP_FLAGS+=(-l "$__FILE__")
            export -- "$k"=1
            continue
        fi
    done
}

import_module builtins
#endregion

# shellcheck source=/dev/null
source "$PAPYRUS_CONF"

function path_resolve() {
    src_dir="$(absolute_path_of "$PAPYRUS_SRC/$PAPYRUS_BASENAME")"
    index_md_file="$src_dir/$PAPYRUS_SRC_INDEX_NAME"

    target_dir="$(absolute_path_of "$PAPYRUS_TARGET")"
    bundle_file="$target_dir/$PAPYRUS_BASENAME.$PAPYRUS_TARGET_BUNDLE_FORMAT"
    preprocessed_md_file="$target_dir/$PAPYRUS_BASENAME/$PAPYRUS_TARGET_PREPROCESSED_NAME"
}

function init() {
    local initializer
    for initializer in "${PAPYRUS_INITIALIZERS[@]}"; do
        "$initializer"
    done
}

init

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
