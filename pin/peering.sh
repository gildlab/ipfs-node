#!/usr/bin/env nix-shell
#! nix-shell -i bash -p jq curl xe dig sed

set -Eeux

. ipfs.sh

get_peers() {
    cat peerlist
}

# extracts only the ids from the peerlist
get_peer_ids() {
    get_peers | grep '[^\/]*$' -o
}

get_p2p_circuit() {
    # ipfs_curl_all "id" "$( get_peer_ids )"
    curl -s -X POST $( ipfs_url "swarm/peers" )
}

peering_add_direct() {
    echo "$1" | xe -j10x ipfs swarm peering add
}

peering_add_service() {
    ipfs_curl_all "swarm/peering/add" "$1"
}

peering_add() {
    ipfs_dispatch peering_add_direct peering_add_service "$1"
}

main_peering() {
    peering_add "$( get_peers )"
    # get_p2p_circuit
}