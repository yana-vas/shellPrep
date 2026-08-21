#!/bin/bash

[[ $# -eq 2 ]] || { echo "Invalid number of args" >&2; exit 1; }
[[ -f "$1" ]] || { echo "The args should be files" >&2; exit 2; }
[[ "$1" =~ .csv$ && "$2" =~ .csv$ ]] || { echo "The files should be .csv" >&2; exit 2; }

file1="$1"
file2="$2"

> "$file2"
while IFS= read -r line; do
    id=$(echo "$line" | cut -d',' -f1)
    other=$(echo "$line" | cut -d',' -f2-)
    if grep -qE "^[0-9]+,${other}$" "$file2"; then
        continue
    fi

    Ai=$(grep -E "^[0-9]+,${other}$" "$file1" | sort -t',' -k1,1n | head -n 1)
    echo "$Ai" >> "$file2"
done < "$file1"
