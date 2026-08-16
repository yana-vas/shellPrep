#!/bin/bash

[[ $# -eq 1 ]] || { echo "Error: We should get only one arg." >&2; exit 1; }
[[ -d "$1" ]] || { echo "Error: The arg should be a dir." >&2; exit 2; }

dir="$1"

potential_rm=$(mktemp)
files_info=$(mktemp)
trap 'rm -f "$potential_rm" "$files_info"' EXIT

while IFS= read -rd $'\0' file; do
    sum=$(sha256sum "$file" | cut -d' ' -f1)
    inode=$(stat -c "%i" "$file")
    echo "$sum $inode $file" >> "$files_info"
done < <(find "$dir" -type f -print0)

while IFS= read -r hashsum; do
    has_hardlinks=0
    single_files=$(mktemp)
    all=$(grep -E "^$hashsum " "$files_info" | cut -d' ' -f2 | sort -u)
    while read -r inode; do
        all_inode_files=$(grep -E "^$hashsum $inode " "$files_info" | cut -d' ' -f3-)
        count=$( echo "$all_inode_files" | wc -l)
        if [[ "$count" -ge 2 ]]; then
            has_hardlinks=1
            echo "$all_inode_files" | head -n1
        elif [[ "$count" -eq 1 ]]; then
            echo "$all_inode_files" >> "$single_files"
        fi
    done <<< "$all"

    if [[ "$has_hardlinks" -eq 1 ]]; then
        cat "$single_files"
    elif [[ "$has_hardlinks" -eq 0 ]]; then
        tail -n +2 "$single_files"
    fi
    rm -f "$single_files"
done < <(cut -d' ' -f1 "$files_info" | sort -u)
