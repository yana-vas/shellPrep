#!/bin/bash

files=$(mktemp)
rs=$(mktemp)

trap 'rm -f "$rs" "$files"' EXIT

for arg in "$@"; do
    if [[ -f "$arg" ]]; then
        echo "$arg" >> "$files"
    elif [[ "$arg" =~ ^-R([^=]+)=(.*)$ ]]; then
        word1="${BASH_REMATCH[1]}"
        word2="${BASH_REMATCH[2]}"

        token="$(pwgen 16 1)"

        echo "$word1 $token $word2" >> "$rs"
    else
        echo "Invalid argument!" >&2
        exit 1
    fi
done

while read -r word1 token word2; do

    while IFS= read -r file; do

        sed -i "/^#/! s/\<$word1\>/$token/g" "$file"
    done < "$files"

done < "$rs"

while read -r word1 token word2; do

    while IFS= read -r file; do
        sed -i "/^#/! s/$token/$word2/g" "$file"
    done < "$files"

done < "$rs"
