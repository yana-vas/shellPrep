#!/bin/bash

[[ $# -eq 3 ]] || { echo "Invalid number or ags." >&2; exit 1; }
[[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || { echo "The first arg should be a number." >&2; exit 2; }
[[ -n "$2" ]] || { echo "The second arg should not be empty" >&2; exit 2; }
[[ -n "$3" ]] || { echo "The third arg should not be empty" >&2; exit 2; }
[[ -r "prefix.csv" && -r "base.csv" ]] || { echo "Missing or unreadble csv files" >&2; exit 4; }

num="$1"
prefix="$2"
unit_s="$3"

prefix_info=$(grep "^[^,]*,${prefix}," "prefix.csv" | tail -n 1)
[[ -n "$prefix_info" ]] || { echo "Can't find $prefix in the prefix.csv file" >&2; exit 3; }

decimal=$( echo "$prefix_info" | cut -d',' -f3)
new_num=$( echo "$num * $decimal" | bc -l)

unit_info=$(grep "^[^,]*,$unit_s," "base.csv" | tail -n 1)
[[ -n "$unit_info" ]] || { echo "Can't find $unit_s in base.csv file" >&2; exit 3; }
unit_n=$(echo "$unit_info" | cut -d',' -f1)
unit_m=$(echo "$unit_info" | cut -d',' -f3)

echo "$new_num $unit_s ($unit_m, $unit_n)"
