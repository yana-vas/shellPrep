#!/bin/bash

[[ "$#" -eq 2 ]] || { echo "There should be exactly two arguments." >&2; exit 1; }
[[ -f "$1" && -r "$1" ]] || { echo "The first arg should be a path to a file." >&2; exit 2; }
[[ "$2" =~ ^[0-9]+$ ]] || { echo "The second arg should be a number." >&2; exit 3; }
[[ "$2" -ge 0 && "$2" -le 26 ]] || { echo "The number should be between 0 and 26." >&2; exit 4; }

k="$2"

start=$((k+1))
end=$((26+k))

alphabet=$( echo "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ" | cut -c "$start"-"$end" )

file="$1"

arg1=$(tr 'A-Z' "$alphabet" < "$file" | grep -E -o '[A-Z]+' | sort -u)
num=$(comm -12 <(echo "$arg1") <(tr 'a-z' 'A-Z' < /usr/share/dict/words | sort -u) | wc -l)
echo "$num"
