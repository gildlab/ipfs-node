#!/usr/bin/env nix-shell
#! nix-shell -i bash -p jq curl xe dig

set -Eeux

. ipfs.sh

get_peers() {
    cat peerlist
}

peering_add_url() {
    ipfs_url "swarm/peering/add"
}

peering_add_direct() {
    echo "$1" | xe -j10x ipfs swarm peering add
}

peering_add_service() {
    sed 's#^#'"$( peering_add_url )"'#g' <<< "$1" | xe -j10x curl -s -X POST
}

peering_add() {
    if is_ipfs_running
        then
            peering_add_direct "$1"
        else
            peering_add_service "$1"
    fi
}

main_peering() {
    peering_add "$( get_peers )"
}