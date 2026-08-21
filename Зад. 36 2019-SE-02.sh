#!/bin/bash

N=10
[[ $# -gt 2 ]] && [[ "$1" == "-n" && "$2" =~ [0-9]+ ]] && { N=$2; shift 2; }

out=$(mktemp)
trap 'rm -f "$out"' EXIT

for file in "$@"; do

    idf=$(basename "$file" .log)
    while IFS= read -r line; do
        timestamp=$(echo "$line" | cut -d' ' -f1,2)
        data=$(echo "$line" | cut -d' '  -f3-)
        echo "${timestamp} ${idf} ${data}" >> "$out"
    done < <(tail -n "$N" "$file")
done

sort "$out"
