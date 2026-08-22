#!/bin/bash

user=$(whoami)
[[ "$user" == "root" ]] || exit 0

all_users=$(ps aux | tail -n +2 | awk '{print $1}' | sort -u)

while IFS= read -r curr_user; do
    count=$(ps aux | grep -E "^${curr_user}[[:space:]]+" | wc -l)
    sum_rss=$(ps aux | grep -E "^${curr_user}[[:space:]]+" | awk '{rss+=$6} END {print rss}')
    avg_rss=$( echo "${sum_rss} / ${count}" | bc -l)
    max_rss=$(ps aux | grep -E "^${curr_user}[[:space:]]+" | awk '{print $6}' | sort -nr | head -n1)
    double_avg=$(echo "2 * $avg_rss" | bc -l)
    if [[ $(echo "$max_rss > $double_avg" | bc) -eq 1 ]]; then
        max_rss_pid=$(ps aux | grep -E "^${curr_user}[[:space:]]+" | awk -v max_rss="$max_rss" '$6==max_rss {print $2}' | head -n1)
        kill -TERM "$max_rss_pid" 2>/dev/null
        sleep 2
        kill -0 "$max_rss_pid" 2>/dev/null && kill -KILL "$max_rss_pid" 2>/dev/null
    fi

    echo "User: $curr_user, processes: $count, total RSS: $sum_rss"
done <<< "$all_users"
