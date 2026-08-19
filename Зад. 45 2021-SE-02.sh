#!/bin/bash

[[ $# -ge 1 ]] || { echo "Args should be at least 1" >&2; exit 1; }

for file in "$@"; do
    [[ -f "$file" && -r "$file" && -w "$file" ]] || { echo "Not valid $file" >&2; continue; }
    serial=$(sed -E "s/;.*$//" "$file" | tr '\n' ' ' | grep -Eo '[0-9]{10}' | head -n 1)

    [[ "$serial" =~ ^[0-9]{10}$ ]] || { echo "Can't find valid serial in $file" >&2; continue; }
    date_today=$(date +'%Y%m%d')
    old_date=$(echo "$serial" | grep -oE '^.{8}')
    tt="${serial#old_date}"

    new_serial=""
    if [[ "$old_date" < "$date_today" ]]; then
        new_serial="${date_today}00"
    elif [[ "$old_date" == "$date_today" ]]; then
        new_serial=$((serial + 1))
    fi

    [[ -n "$new_serial" ]] || { echo "Invalid date seq in $file" >&2; continue; }

    sed -i -E "s/${serial}/${new_serial}/" "$file"
done
