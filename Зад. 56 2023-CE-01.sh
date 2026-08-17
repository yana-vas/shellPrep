#!/bin/bash

[[ $# -eq 2 ]] || { echo "Error: Usage: $0 <CSV_file> <star_type>" >&2; exit 1; }
[[ -f "$1" ]] || { echo "The first arg should be a file." >&2; exit 2; }
[[ -n "$2" ]] || { echo "The second arg can not be an empty string." >&2; exit 3; }

csv_file="$1"
star_type="$2"

constellations=$(mktemp)
info=$(mktemp)
cos_starCount=$(mktemp)
trap 'rm -f "$constellations" "$info" "$cos_starCount"' EXIT

while IFS=, read -r star_name id coord constellation_name curr_star_type period brightnes; do
    [[ "$curr_star_type" == "$star_type" ]] || continue
    [[ "$brightnes" == "--" ]] && continue

    echo "$brightnes $constellation_name" "$star_name" >> "$info"

    if ! grep -xqF "$constellation_name" "$constellations"; then
        echo "$constellation_name" >> "$constellations"
    fi

done < "$csv_file"


while IFS= read -r cos; do
    star_count=$(grep -E "^.+ $cos .+$" "$info" | wc -l)
    echo "$star_count $cos" >> "$cos_starCount"
done < "$constellations"

finalCos=$(sort -nr "$cos_starCount" | head -n1 | cut -d' ' -f2-)

brightest=$(grep -E " $finalCos " "$info" | cut -d' ' -f1 | sort -g | head -n1)

star=$(grep -E "^$brightest $finalCos .+" "$info" | cut -d' ' -f3- | head -n1)

echo "$star"
