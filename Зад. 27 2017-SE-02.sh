#!/bin/bash

[[ $# -eq 3 ]] || { echo "Invalid number of args" >&2; exit 1; }
[[ -d "$1" ]] || { echo "The first arg should be dir" >&2; exit 2; }
[[ -d "$2" ]] || { echo "The second arg should be dir" >&2; exit 3; }
[[ -n "$3" ]] || { echo "The third arg should be a non empty string" >&2; exit 4; }

src="$1"
dst="$2"
abc="$3"

[[ -z "$(find "$dst" -type f)" ]] || { echo "DST is not empty" >&2; exit 5; }

user=$(whoami)
[[ "$user" == "root" ]] || exit 0

while IFS= read -rd $'\0' file; do
    rel_path="${file#$src/}"
    dir_path="$(dirname "$rel_path")"
    mkdir -p "${dst}/${dir_path}" 2>/dev/null
    mv "$file" "${dst}/${rel_path}"
done < <(find "$src" -type f -name "*${abc}*" -print0)
