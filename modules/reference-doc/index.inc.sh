# shellcheck shell=bash
# shellcheck disable=SC2154

: "${PAPYRUS_SRC_REFDOC_NAME:=ref.docx}"
reference_doc_file="$src_dir/$PAPYRUS_SRC_REFDOC_NAME"
[ -e "$reference_doc_file" ] || "${PANDOC:-pandoc}" --print-default-data-file reference.docx > "$reference_doc_file"
PAPYRUS_PANDOC_FLAGS+=(--reference-doc "$reference_doc_file")
