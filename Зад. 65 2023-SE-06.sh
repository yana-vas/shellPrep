#!/bin/bash

[[ $# -eq 2 ]] || { echo "Error: There should be exactly two args." >&2; exit 1; }
[[ -d "$1" ]] || { echo "Error: The first arg should be a dir." >&2; exit 2; }

camera="$1"
lib="$2"

[[ -d "$lib" ]] || mkdir -p "$lib"

photos=$(mktemp)
trap 'rm -r "$photos"' EXIT

while IFS= read -rd $'\0' file; do
    stat_time=$(stat -c '%y' "$file")
    read -r y_m_d h_m_s _ <<< "$stat_time"
    h_m_s=$(echo "$h_m_s" | cut -d'.' -f1)
    echo "$y_m_d $h_m_s" >> "$photos"
done < <(find "$camera" -type f -name "*.jpg" -print0)

sort -o "$photos" "$photos"

start_date=""
end_date=""

while IFS= read -r date hour; do
    if [[ -z "$start_date" && -z "$end_date" ]]; then
        start_date="$date"
        end_date="$date"
        continue
    fi

    end_date_p_1d=$(date -d "$end_date + 1 day" +'%Y-%m-%d')

    if [[ "$date" == "$end_date" ]]; then
        continue
    elif [[ "$date" == "$end_date_p_1d" ]]; then
        end_date="$date"
    elif [[ "$date" > "$end_date_p_1d" ]]; then
        mkdir -p "${lib}/${start_date}_${end_date}"
        start_date="$date"
        end_date="$date"
    fi
done < "$photos"

[[ -z "$start_date" ]] || mkdir -p "${lib}/${start_date}_${end_date}"

while IFS= read -rd $'\0' file; do
    stat_time=$(stat -c '%y' "$file")
    read -r date hour <<< "$stat_time"
    hour=$(echo "$hour" | cut -d'.' -f1)
    for folder in "$lib"/*; do
        folder_name=$(basename "$folder")
        start_date=$(echo "$folder_name" | cut -d'_' -f1)
        end_date=$(echo "$folder_name" | cut -d'_' -f2)
        if [[ "$date" > "$start_date" || "$date" == "$start_date" ]] && [[ "$date" < "$end_date" || "$date" == "$end_date" ]]; then
            cp -n "$file" "${folder}/${date}_${hour}.jpg"
            break
        fi
    done

done < <(find "$camera" -type f -name "*.jpg" -print0)
