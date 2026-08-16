#!/bin/bash


slots="${CTRLSLOTS:-0}"

[[ "$1" == "autoconf" ]] && { echo "yes"; exit 0; }
[[ "$1" == "config" ]] && echo "graph_title SSA drive temperatures
graph_vlabel Celsius
graph_category sensors
graph_info This graph shows SSA drive temp"

for slot in $slots; do
    while IFS= read -r line; do
        line=$(echo "$line" | sed -E 's/^[[:space:]]+//')

        if [[ "$line" =~ ^Smart Array (.+) in Slot .*$ ]]; then
            model="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^Array (.+)$ ]]; then
            array="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^Unassigned$ ]]; then
            array="UN"
        elif [[ "$line" =~ ^physicaldrive (.+)$ ]]; then
            drive="${BASH_REMATCH[1]}"
            drive_clean=$(echo "$drive" | tr -d ':')
        elif [[ "$line" =~ ^Current Temperature (C): (.+)$ ]]; then
            temp="${BASH_REMATCH[2]}"
            id="SSA${slot}${model}${array}${drive_clean}"
            label="SSA${slot} ${model} ${array} ${drive}"

            if [[ "$1" == "config" ]]; then
                echo "${id}.label ${label}"
                echo "${id}.type GAUGE"
            elif [[ $# -eq 0 ]]; then
                echo "${id}.value ${temp}"
            fi
        fi

    done < <(ssacli ctrl slot=$slot pd all show detail)
done
