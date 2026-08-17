#!/bin/bash

[[ $# -eq 1 ]] || { echo "There should be one arg." >&2; exit 1; }
[[ -d "$1" ]] || { echo "The arg should be a dir." >&2; exit 2; }

dir="$1"

output_file=$(mktemp)
trap 'rm -f "$output_file"' EXIT


> "${dir}/foo.conf"
while IFS= read -rd $'\0' file; do
    file_name=$(basename "$file")
    user=${file_name%.cfg}

    bash "${dir}/validate.sh" "$file" > "$output_file"
    status="$?"

    if [[ "$status" -eq 1 ]]; then
        while IFS= read -r line; do
            echo "$file_name: $line" >&2
        done < "$output_file"
    elif [[ "$status" -eq 0 ]]; then
        if ! grep -qE "^${user}:" "${dir}/foo.pwd" 2>/dev/null; then
            passwd=$(pwgen 16 1)
            hashed_passwd=$(mkpasswd "$passwd")
            echo "${user}:${hashed_passwd}" >> "${dir}/foo.pwd"
            echo "${user}:${passwd}"
        fi
        cat "$file" >> "${dir}/foo.conf"
    fi
done < <(find "${dir}/cfg" -type f -name '*.cfg' -print0)
