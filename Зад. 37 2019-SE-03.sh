#!/bin/bash

[[ $# -eq 1 ]] || { echo "Invalid number of args" >&2; exit 1; }
[[ -d "$1" ]] || { echo "The arg should be a dir" >&2; exit 2; }

dir="$1"
STATE_FILE="${dir}/task37_cache.db"

[[ -f "$STATE_FILE" ]] || touch "$STATE_FILE"
mkdir -p "/extracted" 2>/dev/null
while IFS= read -rd $'\0' file; do
    file_name=$(basename "$file");
    if [[ "$file_name" =~ ^([^_]+)_report-([0-9]+)\.tgz$ ]]; then
        NAME="${BASH_REMATCH[1]}"
        TIMESTAMP="${BASH_REMATCH[2]}"
    else
        continue
    fi
    curr_hash=$(sha256sum "$file")
    if grep -xq "$curr_hash" "$STATE_FILE"; then
        continue
    fi

    if tar -tf "$file" | grep -q "meow.txt"; then
        tar -xzOf "$file" meow.txt > "/extracted/${NAME}_${TIMESTAMP}.txt"
    fi

    echo "$curr_hash" >> "$STATE_FILE"

done < <(find "$dir" -name '*.tgz' -print0)
