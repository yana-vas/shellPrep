#!/bin/bash

[[ $# -ge 2 ]] || { echo "Error: There should be at least a second arg." >&2; exit 1; }
[[ "$1" =~ ^[0-9]+$ ]] || { echo "The first arg should be a num." >&2; exit 2; }

secs="$1"
comm=$(echo "$@" | cut -d' ' -f2-)

start_time_exact=$(date +'%s.%N')
start_time=$(date +'%s')
end_time=$((start_time + secs))

shift

i=0
while [[ $(date +'%s') -lt "$end_time" ]]; do
    i=$((i+1))

    "$@"
done

end_real_time=$(date +'%s.%N')
total_seconds=$(echo "$end_real_time - $start_time_exact" | bc -l)
avg=$(echo "$total_seconds / $i" | bc -l)

printf "Ran the command '%s' %s times for %.2f seconds.\n" "$comm" "$i" "$total_seconds"
printf "Average runtime: %.2f seconds.\n" "$avg"
