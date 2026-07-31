#!/bin/bash

# 1. Валидация на аргументите (запазваме твоята напълно)
[[ $# -eq 2 ]] || { echo "There should be two args." >&2; exit 1; }
[[ -n "$1" ]] || { echo "The first argument should be a non empty string." >&2; exit 2; }
[[ -f "$2" ]] || { echo "The second arg should be a file." >&2; exit 3; }

domain="$1"
file="$2"

teams=$(cut -d' ' -f3 "$file" | sort -u)

while IFS= read -r artist; do
    [[ -n "$artist" ]] || continue
    echo "; team $artist"

    groupComposters=$(awk -v t="$artist" '$3 == t {print $2}' "$file")
    groupHostnames=$(awk -v t="$artist" '$3 == t {print $1}' "$file")

    while IFS= read -r comp; do
        while IFS= read -r hn; do
            echo "$comp IN NS ${hn}.${domain}."
        done <<< "$groupHostnames"
    done <<< "$groupComposters"

done <<< "$teams"
