#!/bin/bash

[[ $# -eq 2 ]] || { echo "The arguments should be exactly two." >&2; exit 1; }
[[ -d "$1" ]] || { echo "Error: the first arg is not a dir." >&2; exit 2; }
[[ -d "$2" ]] || { echo "Error: the second arg is not a dir." >&2; exit 3; }

old_dir="$1"
new_dir="$2"

while IFS= read -rd $'\0' file; do
    relative_path="${file#$old_dir/}"
    new_file="${new_dir}/${relative_path}"
    new_file="${new_file%.bcf}.bcf2"

    mkdir -p "$(dirname "$new_file")"
    touch "$new_file"
    while IFS= read line; do
        if [[ "$line" =~ ^(.+)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"
            count_of_key=$(grep -c "$key" "$file")
            if [[ "$count_of_key" -eq 1 ]]; then
                echo "${key}: ${value}" >> "$new_file"
            else
                if [[ -f "$new_file" ]] && grep -q "^$key:" "$new_file"; then
                    continue
                fi
                echo "$key:" >> "$new_file"
                grep "^$key=" "$file" | cut -d= -f2- | sed 's/^/- /' >> "$new_file"
            fi
        fi
    done < "$file"
done < <(find "$old_dir" -type f -name "*.bcf" -print0)
