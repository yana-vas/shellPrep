#!/bin/bash

[[ $# -eq 2 ]] || { echo "Invalid number of args" >&2; exit 1; }
[[ -d "$2" ]] || { echo "The second arg should be a dir" >&2; exit 2; }

dir="$2"

echo "hostname,phy,vlans,hosts,failover,VPN-3DES-AES,peers,VLAN Trunk Ports,license,SN,key" > "$1"
while IFS= read -rd $'\0' file; do
    hostname=$(basename "$file" .log)
    phy=$(grep -E "^Maximum Physical Interfaces" "$file" | cut -d':' -f2 | tr -d ' ')
    license=$(grep -E "^This platform has" "$file" | sed -E 's/.*has an? (.*) license\./\1/')
    vlans=$(grep -E "^VLANs" "$file" | awk -F ' : ' '{print $2}' | tr -d ' ')
    hosts=$(grep -E "^Inside Hosts" "$file" | cut -d':' -f2 | tr -d ' ')
    failover=$(grep -E "^Failover" "$file" | cut -d':' -f2 | tr -d ' ')
    vpn=$(grep -E "^VPN-3DES-AES" "$file" | cut -d':' -f2 | tr -d ' ')
    peers=$(grep -E "^Total VPN Peers" "$file" | cut -d':' -f2 | tr -d ' ')
    vlan=$(grep -E "^VLAN Trunk Ports" "$file" | cut -d':' -f2 | tr -d ' ')
    sn=$(grep -E "^Serial Number" "$file" | cut -d':' -f2 | tr -d ' ')
    key=$(grep -E "^Activation Key" "$file" | cut -d':' -f2 | tr -d ' ')

    echo "$hostname,$phy,$vlans,$hosts,$failover,$vpn,$peers,$vlan,$license,$sn,$key" >> "$1"
done < <(find "$dir" -type f -name '*.log' -print0)
