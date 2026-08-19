#!/bin/bash
[[ $# -eq 1 ]] || { echo "Error: Invalid number of args." >&2; exit 1; }
[[ -n "$1" ]] || { echo "The first arg is empty." >&2; exit 2; }

device="$1"

vir_file="/proc/acpi/wakeup"

device_info=$(awk -v d="$device" '$1 == d { print $3 }' "$vir_file")
[[ -z "$device_info" ]] && { echo "Can't find device in $vir_file" >&2; exit 3; }
[[ "$device_info" == "*disabled" ]] && exit 0
echo "$device" > "$vir_file"
