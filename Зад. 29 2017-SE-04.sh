#!/bin/bash

[[ $# -eq 1 || $# -eq 2 ]] || { echo "There should be at least one arg" >&2; exit 1; }
[[ -d "$1" ]] || { echo "There first arg should be a dir" >&2; exit 2; }

dir="$1"

isThereFile=0
[[ $# -eq 2 ]] && isThereFile=1

if [[ $isThereFile -eq 1 ]]; then
    if [[ -e "$2" && ! -f "$2" ]]; then
        echo "Error: $2 exists and is not a regular file!" >&2
        exit 3
    fi
    if ! touch "$2" 2>/dev/null; then
        echo "There first arg should be a dir" >&2
        exit 2
    fi
    file="$2"
fi

broken_counts=0
while IFS= read -rd $'\0' slink; do
    dst=$(readlink "$slink")
    if [[ -e "$slink" ]]; then
        if [[ $isThereFile -eq 1 ]]; then
            echo "$slink -> $dst" >> "$file"
        else
            echo "$slink -> $dst"
        fi
    else
        broken_counts=$((broken_counts + 1))
    fi
done < <(find "$dir" -type l -print0)

if [[ $isThereFile -eq 1 ]]; then
    echo "Broken symlinks: $broken_counts" >> "$file"
else
    echo "Broken symlinks: $broken_counts"
fi
