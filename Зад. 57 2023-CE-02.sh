#!/bin/bash

[[ $# -eq 3 ]] || { echo "Error: Usage: $0 <file1> <file2> <black_hole>" >&2; exit 1; }
[[ -f "$1" && -f "$2" ]] || { echo "Error: The first two args should be files." >&2; exit 2; }
[[ -n "$3" ]] || { echo "Error: The third arg should not be an empty string." >&2; exit 3; }

point1="$1"
point2="$2"
target="$3"

p1_long=$(grep -F "$target: " "$point1" | cut -d':' -f2 | grep -oE '[0-9]+' | head -n1)
p2_long=$(grep -F "$target: " "$point2" | cut -d':' -f2 | grep -oE '[0-9]+' | head -n1)

[[ -n "$p1_long" && -n "$p2_long" ]] || { echo "Error: can't find the target in the files." >&2; exit 4; }

if [[ "$p1_long" -lt "$p2_long" ]]; then
    echo "$point1"
else
    echo "$point2"
fi
