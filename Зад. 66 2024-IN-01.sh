#!/bin/bash

[[ -n "$ARKCONF" ]] || { echo "Error: There is not such env var ARKCONF." >&2; exit 1; }
[[ -e "$ARKCONF" || -L "$ARKCONF" ]] || { echo "Error: ARKCONF does not exist!" >&2; exit 2; }
[[ -f "$ARKCONF" ]] || { echo "Error: ARKCONF is not a file." >&2; exit 3; }

WHAT="$(grep '^WHAT=' "$ARKCONF" | cut -d'=' -f2- | tr -d '"')"
WHERE="$(grep '^WHERE=' "$ARKCONF" | cut -d'=' -f2- | tr -d '"')"
WHO="$(grep '^WHO=' "$ARKCONF" | cut -d'=' -f2- | tr -d '"')"

[[ -n "$WHERE" && -n "$WHAT" && -n "$WHO" ]] || { echo "Error: Incomplete ARKCONF file!" >&2; exit 7; }

is_push="false"
is_pull="false"
is_d="false"
server=""
for arg in "$@"; do
    if [[ "$arg" == "pull" ]]; then
        is_pull="true"
    elif [[ "$arg" == "push" ]]; then
        is_push="true"
    elif [[ "$arg" == "-d" ]]; then
        is_d="true"
    else
        if echo "$WHERE" | tr ' ' '\n' | grep -qFx "$arg"; then
            server="$arg"
        else
            echo "Error: Unknown arg or server $arg" >&2
            exit 5
        fi
    fi
done

opts="-av"
if [[ "$is_d" == "true" ]]; then
    opts="${opts} --delete"
fi


if [[ "$is_push" == "true" ]] && [[ "$is_pull" == "true" ]]; then
    echo "Error: Can't have push and pull at the same time." >&2
    exit 4
fi

if [[ "$is_push" == "false" && "$is_pull" == "false" ]]; then
    echo "Error: Must specify either pull or push" >&2
    exit 6
fi


servers_to_sync=""
if [[ -n "$server" ]]; then
    servers_to_sync="$server"
else
    servers_to_sync="$WHERE"
fi
    for curr_server in $servers_to_sync; do
        SRC=""
        DST=""
        if [[ "$is_push" == "true" ]]; then
            SRC="${WHAT%/}/"
            DST="${WHO}@${curr_server}:$WHAT/"
        elif [[ "$is_pull" == "true" ]]; then
            SRC="${WHO}@${curr_server}:$WHAT/"
            DST="${WHAT%/}/"
        fi

        echo "Ще правим синхорнизация за $curr_server"
        rsync $opts -n "$SRC" "$DST"
        read -p "Потвърждавате ли синхронизацията за $curr_server? (y/n): " confirm
        if [[ "$confirm" =~ ^[yY](es)?$ ]]; then
            rsync $opts "$SRC" "$DST"
        fi

    done
