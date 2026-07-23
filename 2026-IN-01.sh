#!/bin/bash

[ "$#" -eq 2 ] || { echo "There should be exactly two arguments." >&2; exit 1; }
[ -d "$1" ] || { echo "The first arg should be a dir." >&2; exit 2; }
[[ -f "$2" && -r "$2" ]] || { echo "The second arg should be a readable file." >&2; exit 3; }

dir="$1"
history="$2"

data=$(mktemp)

while IFS= read -r file; do
    if [[ "$file" =~ \.parquet$ ]]; then
        sha_sum=$(sha1sum "$file" | cut -d' ' -f 1)
        date=$(basename "$file" | cut -d'_' -f 2)
        num=$(grep -n "$sha_sum" "$history" | cut -d':' -f1)
        echo "$date $num $file" >> "$data"
    fi
done < <(find "$dir" -type f)

cat "$data" | sort -k1,1  -k2,2nr | awk 'seen[$1]++ { print $3 }' | while read rm_file; do rm "$rm_file"; done
rm "$data"
