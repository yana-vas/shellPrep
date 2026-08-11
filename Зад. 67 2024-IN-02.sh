#!/bin/bash

[[ $# -eq 2 ]] || { echo "Error: there should be exactly two args" >&2; exit 1; }
[[ -d "$1" ]] || { echo "The first arg should be a dir!" >&2; exit 2; }


dir="$1"
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

while IFS= read -rd $'\0' file; do

    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*class ([A-Za-z_][A-Za-z0-9_]*)$ ]]; then
            Cname="${BASH_REMATCH[1]}"
            echo "$Cname" >> "$temp_file"
        elif [[ "$line" =~ ^[[:space:]]*class ([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*:[[:space:]]*(.+)$ ]]; then
            Cname="${BASH_REMATCH[1]}"
            echo "$Cname" >> "$temp_file"
            echo "${BASH_REMATCH[2]}" | tr ',' '\n' | while read -r mode p; do
                echo "$p" >> "$temp_file"
                echo "$p -> $Cname" >> "$temp_file"
            done

        fi
    done < "$file"

done < <(find "$dir" -type f -print0)

dag-ger "$temp_file" > "$2"
[[ "$?" -eq 0 ]] || { echo "Something went wrong while executing dag-ger..." >&2; exit 3; }
