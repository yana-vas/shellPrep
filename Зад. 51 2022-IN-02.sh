#!/bin/bash

[[ $# -eq 1 ]] || { echo "There should be just one arg." >&2; exit 1; }
[[ "$1" =~ ^[0-9]+$ ]] || { echo "The first arg should be a number." >&2; exit 2; }

num="$1"

user=$(whoami)

[[ "$user" == "oracle" || "$user" == "grid" ]] || { echo "Wrong user." >&2; exit 3; }

[[ -n "$ORACLE_BASE" ]] || { echo "There is not an env var called ORACLE_BASE" >&2; exit 4; }
[[ -n "$ORACLE_HOME" ]] || { echo "There is not an env var called ORACLE_HOME" >&2; exit 4; }
[[ -n "$ORACLE_SID" ]] || { echo "There is not an env var called ORACLE_SID" >&2; exit 4; }

role=""
if [[ "$user" == "oracle" ]]; then
    role="SYSDBA"
elif [[ "$user" == "grid" ]]; then
    role="SYSASM"
fi

sql_query=$(mktemp)
echo "SELECT value FROM v\$parameter WHERE name = 'diagnostic_dest';" >> "$sql_query"
echo "EXIT;" >> "$sql_query"

diagnostic_dest=$("${ORACLE_HOME}/bin/sqlplus" -SL "/ as $role" @"$sql_query" | tail -n +4 | head -n1)
trap 'rm -f "$sql_query"' EXIT

status="$?"
[[ "$status" -eq 0 ]] || { echo "Smth went wrong while executing the command sqlplus" >&2; exit 5; }

diag_base=""
if [[ -z "$diagnostic_dest" ]]; then
    diag_base="$ORACLE_BASE"
else
    diag_base="$diagnostic_dest"
fi

diag_dir="diag"

if [[ "$user" == "grid" ]]; then
    machine=$(hostname -s)
    crs_dir="${diag_base}/${diag_dir}/crs/${machine}/crs/trace"

    if [[ -d "$crs_dir" ]]; then
        crs_size=$(find "$crs_dir" -type f \( -name '*_[0-9]*.trc' -o -name '*_[0-9]*.trm' \) -mtime +"$num" -printf '%k\n' | awk '{s+=$1} END {print s+0}')
        echo "crs: $crs_size"
    fi

    tns_dir="${diag_base}/${diag_dir}/tnslsnr/${machine}"

    if [[ -d "$tns_dir" ]]; then
        tns_size=$(find "${tns_dir}" -type f -mtime +"$num" \( -path '*/alert/*_[0-9]*.xml' -o -path '*/trace/*_[0-9]*.log' \) -printf '%k\n' | awk '{s+=$1} END {print s+0}')
        echo "tnslsnr: $tns_size"
    fi
elif [[ "$user" == "oracle" ]]; then

    rdbms_dir="${diag_base}/${diag_dir}/rdbms"
    if [[ -d "$rdbms_dir" ]]; then
        rdbms_size=$(find "$rdbms_dir" -mindepth 3 -maxdepth 3 -type f -mtime +"$num" \( -name '*_[0-9]*.trc' -o -name '*_[0-9]*.trm' \) -printf '%k\n' | awk '{s+=$1} END {print s+0}')
        echo "rdbms: $rdbms_size"
    fi
fi
