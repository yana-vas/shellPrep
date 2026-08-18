#!/bin/bash

[[ $# -eq 2 ]] || { echo "Invlaid number of args." >&2; exit 1; }
[[ -d "$1" && -d "$2" ]] || { echo "The args should be dirs." >&2; exit 2; }
[[ $(find "$2" -mindepth 1 | wc -l) -eq 0 ]] || { echo "$2 is not empty" >&2; exit 3; }

dir1="$1"
dir2="$2"

while IFS= read -rd $'\0' file; do

    dir_name=$(dirname "$file")
    base_name=$(basename "$file")
    if [[ "$base_name" =~ ^\.(.+)\.swp$ ]]; then
        org_file="${BASH_REMATCH[1]}"
        if [[ -f "${dir_name}/${org_file}" ]]; then
            continue
        fi
    fi

    rel_path="${file#"$dir1"/}"
    dest_file="${dir2}/${rel_path}"

    mkdir -p "$(dirname "$dest_file")"
    cp "$file" "$dest_file"
done < <(find "$dir1" -type f -print0)
