#!/usr/bin/env nix-shell
#! nix-shell -i bash -p jq curl xe dig

set -Eeux

. ipfs.sh

# get the hashes from the subgraph
get_hashes () {
    local url='https://api.thegraph.com/subgraphs/name/gild-lab/offchainassetvault'
    local id='0x8058ad7c22fdc8788fe4cb1dac15d6e976127324';
    local query=$( cat << "QUERY"
        query($id: String!) {
            hashes(first:100, skip: 0, orderBy:timestamp, orderDirection: desc) {
                hash
            }
        }
QUERY
    );
    local payload=$( cat << "PAYLOAD"
        {
            query: $query,
            variables: {
                id: $id
            }
        }
PAYLOAD
    );
    local jq_selector='.data.hashes[].hash | select(startswith("Qm"))';

    local body=$( jq -n --arg query "$query" --arg id $id "$payload" );

    curl -X POST -d "$body" $url | jq -r "$jq_selector"
}

pin_add_url() {
    ipfs_url "pin/add"
}

# pin using kubo directly
pin_direct() {
    echo "$1" | xe -j10x ipfs pin add
}

# pin using a service
pin_service() {
    sed 's#^#'"$( pin_add_url )"'#g' <<< "$1" | xe -j10x curl -s -X POST
}

pin_add() {
    if is_ipfs_running
        then 
            pin_direct "$1"
        else 
            pin_service "$1"
    fi
}

# pin the hashes to the ipfs node
main_pin() {
    pin_add "$( get_hashes )"
}