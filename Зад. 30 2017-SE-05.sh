#!/bin/bash

[[ $# -eq 2 ]] || { echo "Invalid number of args" >&2; exit 1; }
[[ -d "$1" ]] || { echo "The first arg should be a dir" >&2; exit 2; }
[[ -n "$2" ]] || { echo "The second arg should a string" >&2; exit 2; }

dir="$1"
str="$2"

out=$(mktemp)
trap 'rm -f "$out"' EXIT

while IFS= read -rd $'\0' file; do
    file_name=$(basename "$file")
    if [[ "$file_name" =~ ^vmlinuz-([0-9]+\.[0-9]+\.[0-9]+)-${str}$ ]]; then
        echo "${BASH_REMATCH[1]}" >> "$out"
    fi
done < <(find "$dir" -maxdepth 1 -type f -name 'vmlinuz-*' -print0)

xyz=$(sort -t '.' -k 1,1nr -k 2,2nr -k 3,3nr "$out" | head -n 1)
[[ -n "$xyz" ]] && echo "vmlinuz-${xyz}-${str}"
