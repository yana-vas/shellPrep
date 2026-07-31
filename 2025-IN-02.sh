#!/bin/bash


[[ $# -eq 2 ]] || { echo "There should be two args." >&2; exit 1; }
[[ -n "$1" ]] || { echo "The first argument should be a non empty string." >&2; exit 2; }
[[ -f "$2" ]] || { echo "The second arg should be a file." >&2; exit 3; }

domain="$1"
file="$2"

output=$(mktemp)
trap 'rm -f "$output"' EXIT

while IFS= read -r line; do
    [[ -n "$line" ]] || continue

    hostname=$(echo "$line" | cut -d' ' -f1)
    composter=$(echo "$line" | cut -d' ' -f2)
    artist=$(echo "$line" | cut -d' ' -f3)

    [[ -n "$hostname" && -n "$composter" && -n "$artist" ]] || { echo "Not valid file content." >&2; exit 4; }

    if grep -q "; team $artist" "$output"; then
        continue
    else
        echo "; team $artist" >> "$output"

        groupComposters=$(grep " $artist" "$file" | cut -d' ' -f2)
        groupHostnames=$(grep " $artist" "$file" | cut -d' ' -f1)

        while IFS= read -r comp; do
            while IFS= read -r hn; do
                in="$comp IN NS ${hn}.${domain}."
                echo "$in" >> "$output"
            done <<< "$groupHostnames"
        done <<< "$groupComposters"
    fi

done < <(sort -k3 "$file")

cat "$output"
