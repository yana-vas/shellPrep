#!/bin/bash

[[ -n "$SVC_DIR" ]] || { echo "There should be a SVC_DIR env arg." >&2; exit 1; }
[[ -d "$SVC_DIR" ]] || { echo "The SVC_DIR should be a dir." >&2; exit 2; }

command="$1"

if [[ "$command" != "start" && "$command" != "stop" && "$command" != "running" && "$command" != "cleanup" ]]; then
    echo "Invalid command: $command" >&2
    exit 3
fi

if [[ "$command" == "start" || "$command" == "stop" ]]; then
    service_name="$2"
    [[ -n "$service_name" ]] || { echo "Error: service name required." >&2; exit 3; }

    grep -q "^name: $service_name$" "${SVC_DIR}"/* &>/dev/null || { echo "Error: service '$service_name' not found." >&2; exit 4; }
fi

running_file=""

while IFS= read -rd $'\0' file; do
    name=$(grep "^name: .*$" "$file" | cut -d' ' -f2-)
    pidfile=$(grep "^pidfile: .*$" "$file" | cut -d' ' -f2-)
    outfile=$(grep "^outfile: .*$" "$file" | cut -d' ' -f2-)
    comm=$(grep "^comm: .*$" "$file" | cut -d' ' -f2-)

    if [[ "$command" == "start" ]]; then
        if [[ -f "$pidfile" ]] && ps -p "$(cat "$pidfile")" &>/dev/null ; then
            continue
        fi
        service_name="$2"
        [[ "$service_name" == "$name" ]] || { continue; }
        eval "$comm" >> "$outfile" 2>&1 &
        echo "$!" > "$pidfile"
    elif [[ "$command" == "stop" ]]; then
        service_name="$2"
        [[ "$service_name" == "$name" ]] || { continue; }
        [[ -f "$pidfile" ]] && ps -p "$(cat "$pidfile")" &>/dev/null || { continue; }
        kill -SIGTERM "$(cat "$pidfile")"
        rm "$pidfile"
    elif [[ "$command" == "running" ]]; then
        [[ -f "$pidfile" ]] && ps -p "$(cat "$pidfile")" &>/dev/null || { continue; }
        echo "$name"
    elif [[ "$command" == "cleanup" ]]; then
        [[ -f "$pidfile" ]] && ! ps -p "$(cat "$pidfile")" &>/dev/null || { continue; }
        rm "$pidfile"
    fi
done < <(find "$SVC_DIR" -type f -print0) | sort
