#!/bin/bash

[[ "$#" -eq 1 ]] || { echo "The argument should be a file." >&2 ; exit 1; }
[[ -f "$1" && -r "$1" ]] || { echo "The argument should be a file and should be readble." >&2 ; exit 2; }

file="$1"
cmd=""
args=""
env_vars=""
workdir=""

while IFS= read -r line || [[ -n "$line" ]]; do
    clean_line=${line%%#*}
    clean_line=$( echo "$clean_line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' )
    [[ -z "$clean_line" ]] && continue
    if [[ "$clean_line" =~ ^CMD[[:space:]]+(.*)$ ]]; then
        cmd="${BASH_REMATCH[1]}"
    elif [[ "$clean_line" =~ ^ARGS[[:space:]]+(.*)$ ]]; then
        args="${BASH_REMATCH[1]}"
    elif [[ "$clean_line" =~ ^ENV[[:space:]]+(.*)$ ]]; then
        env_vars="${BASH_REMATCH[1]}"
    elif [[ "$clean_line" =~ ^WORKDIR[[:space:]]+(.*)$ ]]; then
        workdir="${BASH_REMATCH[1]}"
    fi
done < "$file"

clean_args=$( echo "$args" | sed -E 's/^\[//; s/\]$//; s/,[[:space:]]/ /g' )
clean_env=$( echo "$env_vars" | sed -E 's/[{}]//g; s/^"([^"]+)"[[:space:]]*"([^"]+)"/\1="\2"/g; s/,[[:space;]]*/ /g' )

cd "$workdir" || { echo "Cannot cd to $workdir" >$2; exit 3; }
eval "$clean_env" "$cmd" "$clean_args"
