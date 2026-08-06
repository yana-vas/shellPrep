#!/bin/bash

[[ $# -eq 1 ]] || { echo "There should be exactly one argument." >&2; exit 1; }
[[ -f "$1" ]] || { echo "The arg should be a file." >&2; exit 2; }

file="$1"

user=$(id -un)


[[ "$user" == "root" ]] || exit 3

while read -r start_dir types perms; do

    while IFS= read -rd $'\0' item; do
        curr_perm=$(stat -c "%a" "$item")
        curr_perm="0${curr_perm}"
        mask="0${perms}"

        match=0

        if [[ "$types" == "R" ]]; then
            (( curr_perm == mask )) && match=1
        elif [[ "$types" == "A" ]]; then
            (( (curr_perm & mask) > 0 )) && match=1
        elif [[ "$types" == "T" ]]; then
            (( (curr_perm & mask) == mask )) && match=1
        fi

        if [[ $match -eq 1 ]]; then
            if [[ -d "$item" ]]; then
                chmod 755 "$item" || echo "Cannot change dir $item" >&2
            elif [[ -f "$item" ]]; then
                chmod 664 "$item" || echo "Cannot change file $item" >&2
            fi
        fi
    done < <(find "$start_dir" -mindepth 1 \( -type f -o -type d \) -print0 2>/dev/null)

done < "$file"
