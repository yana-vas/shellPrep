#!/bin/bash

[[ "$#" -eq 1 ]] || { echo "Usage: $0 <dir>" >&2; exit 1; }
[[ -d "$1" ]] || { echo "The argument should be a dir." >&2; exit 2; }

dir="$1"
newDir="${1}/.data"
[[ -d "$newDir" ]] || { mkdir -p "$newDir"; }

while IFS= read -rd $'\0' file; do
    if [[ "$file" == *"/.data/"* ]]; then
        continue; 583B written
    fi

    sha=$(sha256sum "$file" | cut -d' ' -f1)
    targetPath="${newDir}/${sha}"
    if [[ ! -e "$targetPath" ]]; then
        mv "$file" "$targetPath"
    else
        rm "$file"
    fi
    ln -srf "$targetPath" "$file"

done < <(find "$dir" -type f -print0)
