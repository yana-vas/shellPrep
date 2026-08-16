#!/bin/bash

[[ $# -eq 2 ]] || { echo "The script should have two args." >&2; exit 1; }
[[ -e "$1" && -f "$1"  && -r "$1" ]] || { echo "The first arg should be a readable file." >&2; exit 2; }
[[ -d "$2" ]] || { echo "The second arg should be a dir." >&2; exit 3; }

bad_words="$1"
dir="$2"

while IFS= read -rd $'\0' file; do

    while IFS= read -r word; do
        [[ -n "$word" ]] || continue

        # word_len=$(echo "$word" | wc -c)
        # word_len=$((word_len - 1))

        word_len=${#word}
        new_word=""

        while [[ "$word_len" -gt 0 ]]; do
            word_len=$((word_len - 1))
            new_word="${new_word}*"
        done

        sed -i "s/\b$word\b/$new_word/gi" "$file"
    done < "$bad_words"
done < <(find "$dir" -type f -name '*.txt' -print0)
