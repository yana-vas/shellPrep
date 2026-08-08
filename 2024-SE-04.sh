#!/bin/bash

[[ $# -eq 1 ]] || { echo "Error: Usage: $0 <file>" >&2; exit 1; }

file="$1"

control_file="bakefile"
[[ -r "$control_file" ]] || { echo "The file $control_file should be readble!" >&2; exit 2; }


build_file() {
    local target="$1"

    if ! grep -qE "^${target}:" "$control_file"; then
        if [[ -e "$target" ]]; then
            return 0
        else
            echo "No rule to make target $target" >&2
            exit 4
        fi
    fi

    local line=$(grep -E "^${target}:" "$control_file" | head -n 1)
    local deps=$(echo "$line" | cut -d':' -f2)
    local comm=$(echo "$line" | cut -d':' -f3-)

    for dep in $deps; do
        build_file "$dep"
        [[ "$?" -eq 0 ]] || exit 5
    done

    local should_build=0
    if [[ ! -e "$target" ]]; then
        should_build=1
    fi

    for dep in $deps; do
        if [[ "$dep" -nt "$target" ]]; then
            should_build=1
        fi
    done

    if [[ "$should_build" -eq 1 ]]; then
        eval "$comm"
        [[ "$?" -eq 0 ]] || { echo "Error when doing the command $comm" >&2; exit 6; }
    fi

}

build_file "$1"
