#!/bin/bash

[[ $# -eq 2 ]] || { echo "Invalid number of args" >&2; exit 1; }

repo_path="$1"
pack_path="$2"

[[ -d "$repo_path" && -d "$pack_path" ]] || { echo "There are not such dirs $1 and  $2" >&2; exit 2; }
[[ -f "${pack_path}/version" && -d "${pack_path}/tree" ]] || { echo "Not valid dirs" >&2; exit 2; }

pkg_name=$(basename "$pack_path")
pkg_version=$(cat "${pack_path}/version")

archive=$(mktemp)
trap 'rm -f "$archive"' EXIT

tar -cJf "$archive" -C "${pack_path}/tree" .

checksum=$(sha256sum "$archive" | cut -d' ' -f1)

db_file="${repo_path}/db"
packages_dir="${repo_path}/packages"

if grep -qE "^${pkg_name}-${pkg_version}" "$db_file"; then
    old_line=$(grep -E "^${pkg_name}-${pkg_version}" "$db_file")
    old_checksum=$(echo "$old_line" | cut -d' ' -f2)
    rm -f "${packages_dir}/${old_checksum}.tar.xz"
    sed -i -E "/^${old_line}/d" "$db_file"
fi

cp "$archive" "${packages_dir}/${checksum}.tar.xz"
echo "${pkg_name}-${pkg_version} ${checksum}" >> "$db_file"

sort -o "$db_file" "$db_file"
