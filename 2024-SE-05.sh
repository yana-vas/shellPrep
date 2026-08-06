#!/bin/bash

[[ "$#" -eq 2 ]] || { echo "Error: There should be exactly two args." >&2; exit 1; }


comm="$1"
file="$2"

comm_val=$(eval "$comm")
[[ "$?" -eq 0 ]] || exit 3
comm_exit="$?"

curr_time=$(date +'%Y-%m-%d %A %H')

read -r y_m_d curr_day curr_hour <<< "$curr_time"

echo "$curr_time $comm_val" >> "$file"

alpha=0.0
count=0
while IFS= read -r date day hour val; do
        { [[ "$curr_day" == "$day" ]] &&        [[ "$curr_hour" == "$hour" ]]; } || continue
                count=$(echo "$count + 1" | bc)
                alpha=$(echo "$alpha + $val" | bc -l)

done < "$file"

alpha=$(echo "$alpha / $count" | bc -l)

lower_limit=$(echo "$alpha / 2" | bc -l)
upper_limit=$(echo "$alpha * 2" | bc -l)

ans_1=$(echo "$lower_limit <= $comm_val" | bc)
ans_2=$(echo "$comm_val <= $upper_limit" | bc)

if [[ "$ans_1" -eq 1 && "$ans_2" -eq 1 ]]; then
        exit 0
else
        printf "%s %s: %.4f abnormal\n" "$y_m_d" "$curr_hour" "$comm_val"
        exit 2
fi
