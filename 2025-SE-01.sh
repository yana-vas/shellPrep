  1 #!/bin/bash
  2
  3 [[ "$#" -eq 2 ]] || { echo "There should be two args." >&2; exit 1; }
  4 [[ -f "$1" && -f "$2" ]] || { echo "Usage: $0 <config_file> <input_file>." >&2; exit 2; }
  5
  6 config_file="$1"
  7 input_file="$2"
  8
  9 while IFS= read -r line; do
 10     [[ -n "$line" ]] || continue
 11
 12
 13     lang=$(echo "$line" | cut -d' ' -f1)
 14     output_files=$(echo "$line" | cut -d' ' -f2- | cut -d"'" -f1)
 15     base_output_dir=$(echo "$line" | cut -d' ' -f2- | cut -d"'" -f2)
 16
 17     filename=$(basename "$input_file")
 18     name="${filename%.*}"
 19
 20     output_dir="${base_output_dir}/${name}"
 21
 22     options=""
 23
 24     if [[ "$output_files" == *visitor* ]]; then
 25         options="${options} -visitor"
 26     fi
 27
 28     if [[ "$output_files" != *listener* ]]; then
 29         options="${options} -no-listener"
 30     fi
 31
 32     antlr4 -Dlanguage="$lang" $options -o "$output_dir" "$input_file"
 33 done < "$config_file"
