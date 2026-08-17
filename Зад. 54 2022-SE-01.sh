#!/bin/bash

[[ $# -eq 1 ]] || { echo "There should be just one arg." >&2; exit 1; }
[[ -f "$1" ]] || { echo "The arg should be a file." >&2; exit 2; }

conf="$1"

while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line=$(echo "$line" | sed -E "s/^[[:space:]]+//; s/[[:space:]]+$//" )
    [[ -z "$line" ]] && continue

    if [[ "$line" =~ ^[[:space:]]*([A-Za-z0-9]{1,4})[[:space:]]+(enabled|disabled)[[:space:]]*$ ]]; then
        device="${BASH_REMATCH[1]}"
        wanted_status="${BASH_REMATCH[2]}"
    else
        echo "Wrong syntaxis in the $conf file!" >&2
        continue
    fi

    vir_file="/proc/acpi/wakeup"


    vir_file_device=$(grep -E "^$device[[:space:]]+" "$vir_file")
    [[ -z "$vir_file_device" ]] && { echo "Warning: Device $device does not exist!" >&2; continue; }



        curr_status=$(echo "$vir_file_device" | awk '{print $3}' | tr -d '*')

        [[ "$curr_status" == "$wanted_status" ]] && continue

        echo "$device" > "$vir_file"
done < "$conf"
