# shellcheck shell=bash
# shellcheck disable=SC2154

use_default PAPYRUS_TARGET_BUNDLE_FORMAT:=docx

PAPYRUS_YPP_FLAGS+=(-l "$__MODULE_ROOT__/index.lua")
PAPYRUS_INITIALIZERS+=(__office_word_format_assert)
function __office_word_format_assert() {
    local format="${bundle_file##*.}"
    [[ "${format,,}" = 'docx' ]]
}
