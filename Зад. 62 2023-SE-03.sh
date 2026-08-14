#!/bin/bash

[[ $# -eq 1 ]] || { echo "There should be just one arg." >&2; exit 1; }
[[ -d "$1" ]] || { echo "The arg should be a dir." >&2; exit 2; }

dir="$1"
stopwords=$(mktemp)
final_stopwords=$(mktemp)
trap 'rm -r "$stopwords" "$final_stopwords"' EXIT

all_files=$(find "$dir" -type f | wc -l)
half_files=$(( (all_files+1) / 2 ))

while IFS= read -rd $'\0' file; do
    count_and_words=$(grep -Eo '[a-z]+' "$file" | sort | uniq -c)

    while read -r count word; do
        if [[ "$count" -ge 3 ]]; then
            echo "$word $count $file" >> "$stopwords"
        fi
    done <<< "$count_and_words"

done < <(find "$dir" -type f -print0)

while read -r file_count word; do
    if [[ "$file_count" -ge "$half_files" ]]; then
        count=$(grep -E "^$word " "$stopwords" | awk '{sum += $2} END {print sum}')

        echo "$count $word" >> "$final_stopwords"
    fi
done < <(sort "$stopwords" | cut -d' ' -f1 | uniq -c)

sort -nr "$final_stopwords" | head -n10 | while read -r _ word; do
    echo "$word"
done
