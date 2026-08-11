#!/bin/bash

occ_dir="$(dirname "$(realpath "$0")")"
occ="${occ_dir}/occ"

[[ -e "$occ" || -L "$occ" ]] || { echo "Error: occ does not exist!" >&2; exit 1; }
[[ -x "$occ" ]] || { echo "Error: occ is not executable." >&2; exit 2; }
PASSWD_FILE="${PASSWD:-/etc/passwd}"
local_users=$(mktemp)
PrevCloud=$(mktemp)
trap 'rm -f "$local_users" "$PrevCloud"' EXIT
"${occ_dir}/occ" user:list > "$PrevCloud"

while IFS= read -r line || [[ -n "$line" ]]; do
    uid=$( echo "$line" | cut -d':' -f3)
    user=$( echo "$line" | cut -d':' -f1)
    if [[ $uid -ge 1000 ]]; then
        echo "$user" >> "$local_users"
        if grep -qE "^- ${user}: " "$PrevCloud"; then
            info="$("$occ" user:info "$user")"
            enable=$( echo "$info" | grep -- "- enabled: " | cut -d' ' -f3)
            if [[ "$enable" == "false" ]]; then
                "${occ_dir}/occ" user:enable "$user"
            fi
        else
            "${occ_dir}/occ" user:add "$user"
        fi
    fi

done < "$PASSWD_FILE"

while IFS= read -r line || [[ -n "$line" ]]; do
    user=$(echo "$line" | cut -d':' -f1 | cut -d' ' -f2)
    if ! grep -qFx "$user" "$local_users"; then
        info="$("$occ" user:info "$user")"
        enable=$( echo "$info" | grep -- "- enabled: " | cut -d' ' -f3)
        if [[ "$enable" == "true" ]]; then
            "${occ_dir}/occ" user:disable "$user"
        fi
    fi
done < "$PrevCloud"
