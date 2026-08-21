#!/bin/bash

[[ $# -eq 3 ]] || { echo "Invalid number of args" >&2; exit 1; }
[[ -f "$1" && -r "$1" ]] || { echo "The first arg should be a readble file" >&2; exit 2; }
[[ -n "$2" && -n "$3" ]] || { echo "The second and thir arg should be a non empty string" >&2; exit 2; }

file="$1"
str1="$2"
str2="$3"

str1_in_file=$(grep -E "^${str1}=" "$file")
str2_in_file=$(grep -E "^${str2}=.+$" "$file")
[[ -n "$str2_in_file" ]] || exit 0

val1=$(echo "$str1_in_file" | cut -d'=' -f2-)
val2=$(echo "$str2_in_file" | cut -d'=' -f2-)
vals=$( echo "${val1} ${val2}" | sort | uniq -c)

new_val=""
for t in $val2; do
    if ! echo "$val1" | grep -qw "$t"; then
        new_val="${new_val} ${t}"
    fi
done

new_val=$(echo "$new_val" | xargs)
sed -i -E "s/^${str2}=.*$/${str2}=${new_val}/" "$file"
