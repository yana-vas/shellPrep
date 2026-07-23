#!/bin/bash

[[ "$#" -eq 1 ]] || { echo "There should be one arg." >&2; exit 1; }
[[ -f "$1" && -r "$1" ]] || { echo "The arg should be a file and should be readble" >&2; exit 1; }

file="$1"

temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

process_file() {
    local current_dir
    current_dir=$(dirname "$1")

    [[ -f "$1" && -r "$1" ]] || { return 2; }

    local abs_path
    abs_path=$(realpath "$1")
    if echo "$2" | grep -qFx "$abs_path"; then
        return 3
    fi

    local new_visited
    new_visited="$2"$'\n'"$abs_path"

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^\!include:[[:space:]]*(.*)$ ]]; then
            path=${BASH_REMATCH[1]}
            local target_file
            target_file="$current_dir/$path"
            process_file "$target_file" "$new_visited" || return $?
        else
            echo "$line"
        fi
    done < "$1"
}

process_file "$file" "" > "$temp_file"
status=$?
