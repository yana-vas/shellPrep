  1 #!/bin/bash
  2
  3 [[ $# -eq 1 ]] || { echo "Invalid number of args" >&2; exit 1; }
  4 [[ -f "$1" && -r "$1" ]] || { echo "The arguments should be a readble file" >&2; exit 2; }
  5
  6 file="$1"
  7
  8 top3=$(cut -d' ' -f2 "$file" | sort | uniq -c | sort -nr | head -n 3 | sed -E "s/^[[:space:]]*//g")
  9
 10 while read -r count website; do
 11     count_http2_0=$(grep -E "^.* ${website} .*$" "$file" | grep -E "^.* ${website} .* \[.*\] (GET|POST) /.* HTTP/2\.0 [0-9]+ [0-9]+ \".*\"$" | wc -l)
 12     count_non_http2_0=$(( count - count_http2_0))
 13     echo "${website} HTTP/2.0: $count_http2_0 non-HTTP/2.0: $count_non_http2_0"
 14     top5=$(grep -E "^.* ${website} " "$file" | awk '$9 > 302 { print $1 }' | sort | uniq -c | sort -nr | head -n 5)
 15     [[ -n "$top5" ]] && echo "$top5"
 16 done <<< "$top3"
