#!/bin/bash

[[ $# -eq 3 ]] || { echo "Invalid number of args" >&2; exit 1; }
[[ -f "$1" && -r "$1" && -w "$1" ]] || { echo "The file $1 is either missing or unreadble" >&2; exit 2; }
[[ -n "$2" && -n "$3" ]] || { echo "Some of the args are empty" >&2; exit 2; }

conf_file="$1"
key="$2"
val="$3"

should_size=$(sed -E "s/#.*$//" "$conf_file" | wc -l)
invalid_lines=$(sed -E "s/#.*$//" "$conf_file" | grep -vE "^[[:space:]]*$" | grep -vE "^[[:space:]]*[a-zA-Z0-9_]+[[:space:]]*=[[:space:]]*[a-zA-Z0-9_]+[[:space:]]*$")
[[ -z "$invalid_lines" ]] || { echo "Conf file is not valid" >&2; exit 3; }

val_in_file=$(sed -E "s/#.*$//" "$conf_file" | grep -E "^[[:space:]]*${key}[[:space:]]*=" | head -n 1 | xargs | tr -d ' ' | cut -d'=' -f2)

user=$(whoami)
d=$(date)

if [[ -z "$val_in_file" ]]; then
    echo "${key} = ${val} # added at $d by $user" >> "$conf_file"
elif [[ "$val_in_file" != "$val" ]]; then
    line=$(grep -E "^[[:space:]]*$key[[:space:]]*=[[:space:]]*$val_in_file[[:space:]]*" "$conf_file")
    sed -i -E "s|^([[:space:]]*${key}[[:space:]]*=.*)$|# \1 # edited at ${d} by ${user}\n${key} = ${val} # added at ${d} by ${user}|" "$conf_file"
fi
