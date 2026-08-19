#!/bin/bash

[[ $# -eq 3 ]] || { echo "Invalid number of args" >&2; exit 1; }
[[ -f "$1" && -d "$3" ]] || { echo "Usage: $0 <file1> <file2> <dir>" >&2; exit 2; }

file1="$1"
file2="$2"
dir="$3"

> "$file2"
while IFS= read -rd $'\0' file; do
    is_valid=0
    i=0
    while IFS= read -r line; do
        i=$((i+1))
        if echo "$line" | grep -qE "^#.*$"; then
            continue
        fi
        if echo "$line" | grep -vqE "^{ (no-production|volatile|run-all;) };$"; then
            if [[ "$is_valid" -eq 0 ]]; then
                is_valid=1
                echo "Error in $(basename $file):"
            fi
            echo "Line $i:$line"
        fi
    done < "$file"

    if [[ "$is_valid" -eq 0 ]]; then
        base_name=$(basename "$file")
        user="${base_name%%.*}"
        if ! grep -qE "^${user}" "$file1"; then
            new_pass=$(pwgen 16 1)
            hash=$(echo "$new_pass" | md5sum | cut -d' ' -f1)
            echo "${user}:${hash}" >> "$file1"
            echo "$user $new_pass"
        fi
        cat "$file" >> "$file2"
    fi
done < <(find "$dir" -type f -name '*.cfg' -print0)
