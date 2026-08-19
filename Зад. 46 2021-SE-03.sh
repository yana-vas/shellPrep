#!/bin/bash

[[ $# -eq 2 ]] || { echo "There should be two args" >&2; exit 1; }
[[ -f "$1" && -r "$1" ]] || { echo "The args should be files" >&2; exit 2; }

input="$1"

in_size=$(stat -c '%s' "$input")
[[ $((in_size % 2)) == 0 && $in_size -le $((524288 * 2)) ]] || { echo "Wrong size of input file" >&2; exit 2; }

arrN=$(( in_size / 2))

formatted_nums=$(od -An -v -t u2 "$input" | xargs | tr ' ' ',')

echo "#include <stdint.h>" > "$2"
echo "const uint32_t arrN = ${arrN};" >> "$2"
echo "const uint16_t arr[] = { ${formatted_nums} };" >> "$2"
