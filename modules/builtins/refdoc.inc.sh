# shellcheck shell=bash
# shellcheck disable=SC2154

PAPYRUS_INITIALIZERS+=(__builtins_refdoc_setup)
function __builtins_refdoc_setup() {
    [[ -v REFDOC_BASENAME ]] \
        || return 0

    local target_format="$PAPYRUS_TARGET_BUNDLE_FORMAT"
    reference_doc_file="$src_dir/$REFDOC_BASENAME.$target_format"
    [[ -e "$reference_doc_file" ]] || "${PANDOC:-pandoc}" --print-default-data-file \
        "reference.$target_format" > "$reference_doc_file"

    PAPYRUS_PANDOC_FLAGS+=(
        --reference-doc="$reference_doc_file"
    )
}

function use_refdoc() {
    if [[ $# -eq 0 ]]; then
        eval set -- ref
    fi

    declare -g -- REFDOC_BASENAME="$1"
}
