#!/bin/bash

heavy_file=$(mktemp)
trap 'rm -r "$heavy_file"' EXIT

i=0
while true; do
    i=$((i+1))
    echo "Итерация $i завърши. Чакам тежките процеси да спрат..."
    ps_file=$(ps -eo comm=,rss= | awk '{ sum[$1] += $2 } END { for (c in sum) print c, sum[c] }')

    has_heavy="false"
    while read -r comm total_rss; do

        if [[ "$total_rss" -gt 65536 ]]; then
            echo "$comm" >> "$heavy_file"
            has_heavy="true"
        fi
    done <<< "$ps_file"

    if [[ "$has_heavy" == "false" ]]; then
        break
    fi
    sleep 1
done

half=$(((i+1) / 2))

while read -r count comm; do
    if [[ "$count" -ge "$half" ]]; then
        echo "$comm"
    fi
done < <(sort "$heavy_file" | uniq -c)
