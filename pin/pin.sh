#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bash jq curl xe dig

set -Eeuxo pipefail

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

# determine if kubo is available direct
is_ipfs_running() {
    ipfs id &>/dev/null
}

# pin using kubo directly
pin_direct() {
    echo "$0" | xe -j10x ipfs pin add
}

# detect the host of the service
service_host() {
    if [ -z $( dig +short gl_ipfs ) ]
        then
            echo "localhost"
        else
            echo "gl_ipfs"
    fi
}

# pin using a service
pin_service() {
    local url="http://$( service_host ):5001/api/v0/pin/add?arg=";
    sed 's#^#'"$url"'#g' <<< "$1" | xe -j10x curl -s -X POST
}

# pin the hashes to the ipfs node
pin_hashes() {
    local hashes="$( get_hashes )"
    if is_ipfs_running
        then 
            pin_direct "$hashes"
        else 
            pin_service "$hashes"
    fi
}

# main loop
loop() {
    while true
        do
            pin_hashes
            sleep 10
        done
}

if $1
    then loop
    else pin_hashes
fi