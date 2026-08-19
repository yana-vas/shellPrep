#!/bin/bash

user=$(whoami)
[[ "$user" == "oracle" || "$user" == "grid" ]] || { echo "invlaid user $user. Should be \"oracle\" or \"grid\"." >&2; exit 1; }
[[ -n "$ORACLE_HOME" ]] || { echo "Can't find env var ORACLE_HOME" >&2; exit 2; }

exec_adrici="${ORACLE_HOME}/bin/adrci"
diag_dest="/u01/app/${user}"

[[ -x "$exec_adrici" ]] || { echo "adrci is not executable!" >&2; exit 3; }
output=$($exec_adrici exec="show homes" | tail -n +2)
[[ -z "$output" ]] && { exit 0; }

while IFS= read -r line; do
    abs_path="${diag_dest}/${line}"
    mb=$(du -s -m "$abs_path" | cut -f1)
    echo "$mb $abs_path"
done <<< "$output"
