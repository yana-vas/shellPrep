#!/bin/bash

[[ $# -eq 2 ]] || { echo "Invalid number of args" >&2; exit 1; }
[[ -d "$1" ]] || { echo "The first arg should be a dir" >&2; exit 2; }

src="$1"
dst="$2"

mkdir -p "${dst}/images"
while IFS= read -rd $'\0' file; do

    filename=$(basename "$file")
    title=$(echo "$filename" | sed -E "s/\([^)]*\)//g" | sed -E "s/\.jpg$//" | xargs )
    album=$(echo "$filename" | xargs | grep -oE "\([^)]*\)" | tail -n 1 | sed "s/(//; s/)//")

    [[ -z "$album" ]] && album="misc"

    date=$(stat -c %y "$file" | cut -d' ' -f1)
    hash_sum=$(sha256sum "$file" | cut -d' ' -f1 | grep -Eo "^.{16}")

    path="${dst}/images/${hash_sum}.jpg"
    cp "$file" "$path"

    link1_path="${dst}/by-date/${date}/by-album/${album}/by-title/${title}.jpg"
    mkdir -p "$(dirname "$link1_path")"
    link2_path="${dst}/by-date/${date}/by-title/${title}.jpg"
    mkdir -p "$(dirname "$link2_path")"
    link3_path="${dst}/by-album/${album}/by-date/${date}/by-title/${title}.jpg"
    mkdir -p "$(dirname "$link3_path")"
    ln -s -r "$path" "$link3_path"
    link4_path="${dst}/by-album/${album}/by-title/${title}.jpg"
    link5_path="${dst}/by-title/${title}.jpg"
    mkdir -p "$(dirname "$link5_path")"
    ln -s -r "$path" "$link5_path"
    mkdir -p "$(dirname "$link4_path")"
    ln -s -r "$path" "$link4_path"
    ln -s -r "$path" "$link2_path"
    ln -s -r "$path" "$link1_path"
done < <(find "$src" -type f -name '*.jpg' -print0)
