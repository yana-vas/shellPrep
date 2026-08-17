#!/bin/bash

[[ $# -eq 2 ]] || { echo "Error: The script should have exactly two args." >&2; exit 1; }
[[ -d "$1" ]] || { echo "Error: The first arg should be a dir." >&2; exit 2; }
[[ "$2" =~ ^[0-9]+$ ]] || { echo "Error: The second arg should be a nuber." >&2; exit 3; }
[[ "$2" -gt 0 && "$2" -lt 100 ]] || { echo "Error: The second arg should be in the interval [1, 99]." >&2; exit 3; }

dir="$1"
num="$2"

curr_usage=$(df -P "$dir" | tail -n1 | awk '{print $5}' | tr -d '%')

[[ "$curr_usage" -le "$num" ]] && exit 0

find "$dir" -xtype l -delete

objects=$(find "$dir" -type f -name '*.tar.xz' | xargs -n1 basename | cut -d'-' -f1-2 | sort -u)

rm_files=$(mktemp)
trap 'rm -f "$rm_files"' EXIT

for c in $(seq 0 3); do
    k=$((c + 1))

    while IFS= read -r obj; do

        files=$(find "${dir}/${c}" -type f -name "${obj}-[0-9]*.tar.xz" 2>/dev/null | sort)
        total_count=$(echo "$files" | sed '/^$/d' | wc -l )

        if [[ "$total_count" -gt "$k" ]]; then
            count_rm=$((total_count - k))
            echo "$files" | head -n "$count_rm" >> "$rm_files"
        fi

    done <<< "$objects"
done

while IFS= read -r f; do
    curr_usage=$(df -P "$dir" | tail -n1 | awk '{print $5}' | tr -d '%')
    [[ "$curr_usage" -le "$num" ]] && break
    rm -f "$f"
    find "$dir" -xtype l -delete
done < "$rm_files"
