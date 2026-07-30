#!/bin/bash

[[ "$#" -ge 1 ]] || { echo "There should be at least one arg that is path." >&2; exit 1; }

[[ -n "$REGISTRY_FILE" ]] || { echo "REGISTRY_FILE is not set." >&2; exit 2; }
[[ -n "$REPORTS_DIR" ]] || { echo "REPORTS_DIR is not set." >&2; exit 3; }

[[ -f "$REGISTRY_FILE" ]] || { mkdir -p "$(dirname "$REGISTRY_FILE")"; touch "$REGISTRY_FILE"; }
[[ -d "$REPORTS_DIR" ]] || { mkdir -p "$REPORTS_DIR"; }

new=$(mktemp)
unchanged=$(mktemp)
modified=$(mktemp)
new_register=$(mktemp)
trap 'rm -f "$new" "$modified" "$unchanged" "$new_register"' EXIT


for arg in "$@"; do
    [[ -d "$arg" ]] || { echo "The arg should be a dir." >&2; exit 4; }

    while IFS= read -rd $'\0' file; do
        abs=$(realpath "$file")
        hash=$(sha256sum "$file" | cut -d' ' -f1)

        old_line=$(grep -E "  $abs$" "$REGISTRY_FILE")
        if [[ -n "$old_line" ]]; then
            old_hash=$( echo "$old_line" | cut -d' ' -f1)

            if [[ "$old_hash" == "$hash" ]]; then
                echo "$abs" >> "$unchanged"
                echo "$hash  $abs" >> "$new_register"
            else
                echo "$abs" >> "$modified"
                echo "$hash  $abs" >> "$new_register"
            fi
        else
            echo "$abs" >> "$new"
            echo "$hash  $abs" >> "$new_register"
        fi
    done < <(find "$arg" -type f -print0)
done

timestamp=$(date +%Y-%m-%d-%H-%M-%S)
new_file="${REPORTS_DIR}/$timestamp.report"
touch "$new_file"

echo "new:" > "$new_file"
cat "$new" >> "$new_file"
echo "modified:" >> "$new_file"
cat "$modified" >> "$new_file"
echo "unchanged:" >> "$new_file"
cat "$unchanged" >> "$new_file"

cat "$new_register" > "$REGISTRY_FILE"
