#!/bin/bash

[[ $# -eq 1 ]] || { echo "Invalid number of args." >&2; exit 1; }
[[ "$1" =~ ^[0-9]+$ && $1 -gt 1 ]] || { echo "The first arg should be number (min value of number is 2)" >&2; exit 2; }

num="$1"

user=$(whoami)
[[ "$user" == "oracle" || "$user" == "grid" ]] || { echo "Incorrect user." >&2; exit 3; }

diag_dest="/u01/app/${user}"
[[ -d "$diag_dest" ]] || { echo "Can't find dir $diag_dest" >&2; exit 3; }

[[ -n "$ORACLE_HOME" ]] || { echo "There is not such env var ORACLE_HOME" >&2; exit 3; }

file="${ORACLE_HOME}/bin/adrci"

output=$("${file}" exec="SET BASE ${diag_dest}; SHOW HOMES")

while IFS= read -r line; do
    w=$( echo "$line" | cut -d'/' -f2)
    if [[ "$w" == "crs" || "$w" == "tnslsnr" || "$w" == "kfod" || "$w" == "asm" || "$w" == "rdbms" ]]; then
        minutes=$(( num * 60 ))
        "${file}" exec="SET BASE ${diag_dest}; SET HOMEPATH ${line}; PURGE -AGE ${minutes}"
    fi
done < <(echo "$output" | grep '^diag/')
