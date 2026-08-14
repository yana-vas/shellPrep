#!/bin/bash

[[ $# -eq 1 ]] || { echo "Error: The script allows only one arg." >&2; exit 1; }
[[ -d "$1" ]] || { echo "Error: The arg should be a dir." >&2; exit 2; }

dir="$1"

files_sum=$(mktemp)
trap 'rm -rf "$files_sum"' EXIT

while IFS= read -rd $'\0' file; do
    echo "$(sha256sum "$file")" >> "$files_sum"
done < <(find "$dir" -type f -print0)

deduplicate_count=0
freed_space=0

while read -r sum; do

    count=$(grep -E "^$sum" "$files_sum" | wc -l)

    [[ "$count" -eq 1 ]] && continue

    org_file=$(grep -E "^$sum" "$files_sum" | cut -d' ' -f3- | head -n1)
    other_files=$(grep -E "^$sum" "$files_sum" | cut -d' ' -f3- | tail -n +2)

    deduplicate_count=$((deduplicate_count + 1))

    while read -r other_file; do

        size=$(stat -c "%s" "$other_file")
        freed_space=$((freed_space + size))

        rm "$other_file"
        ln "$org_file" "$other_file"

    done <<< "$other_files"

done < <(awk '{print $1}' "$files_sum" | sort | uniq -d)

echo "Deduplicate count: $deduplicate_count"
echo "Freed space: $freed_space"
