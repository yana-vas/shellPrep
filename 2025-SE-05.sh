#!/bin/bash

[[ "$#" -eq 1 ]] || { echo "There should be one arg." >&2; exit 1; }
[[ -d "$1" ]] || { echo "The arg should be a dir." >&2; exit 2; }

dir="$1"

curr_user=$(whoami)
dir_group_owner=$(stat -c "%G" "$dir")
curr_user_group=$(id -nG)

if [[ "$curr_user" == "root" ]]; then
    while IFS= read -rd $'\0' item; do
        chown :"$dir_group_owner" "$item"
        if [[ -d "$item" ]]; then
            chmod u+rwx,g+rws,o-rwx "$item"
        elif [[ -f "$item" ]]; then
            chmod u+rw,g+rw,o-rwx "$item"
        fi
    done < <(find "$dir" -print0)
elif id -nG | tr ' ' '\n' | grep -Fxq "$dir_group_owner"; then
    umask 007
else
    echo "Error: user not in the group" >&2
    exit 3
fi
