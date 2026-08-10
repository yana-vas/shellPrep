#!/bin/bash

[[ $# -eq 1 ]] || { echo "There should be one arg." >&2; exit 1; }
[[ "$1" =~ ^[0-9]+$ ]] || { echo "The arg should be a number" >&2; exit 2; }
[[ "$1" -ge 0 ]] || { echo "The arg should be a positive number." >&2; exit 2; }

n=$(( $1 % 12 ))

start=$((n+1))
end=$((12+n))

original="A Bb B C Db D Eb E F Gb G Ab"

scheme=$( echo "A Bb B C Db D Eb E F Gb G Ab A Bb B C Db D Eb E F Gb G Ab" | cut -d' ' -f"$start"-"$end")

tones="Bb Db Eb Gb Ab A B C D E F G"

s1=$(
    for chord in $tones; do
        echo "s/\[$chord/[#$chord#/g"
    done
)

s2=$(
    for i in $(seq 1 12); do
        chord=$( echo "$original" | cut -d' ' -f"$i")
        new_chord=$(echo "$scheme" | cut -d' ' -f"$i")
        echo "s/\[\#$chord\#/[$new_chord/g"
    done
)

sed -u "$s1" | sed -u "$s2"
