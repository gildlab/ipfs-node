#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bash jq curl xe

set -Eeuxo pipefail

url='https://api.thegraph.com/subgraphs/name/gild-lab/offchainassetvault'
id='0x8058ad7c22fdc8788fe4cb1dac15d6e976127324';
query=$( cat << "QUERY"
    query($id: String!) {
        hashes(first:100, skip: 0, orderBy:timestamp, orderDirection: desc) {
            hash
        }
    }
QUERY
);
payload=$( cat << "PAYLOAD"
    {
        query: $query,
        variables: {
            id: $id
        }
    }
PAYLOAD
);
jq_selector='.data.hashes[].hash | select(startswith("Qm"))';

body=$( jq -n --arg query "$query" --arg id $id "$payload" );

hashes=$( curl -X POST -d "$body" $url | jq -r "$jq_selector" );

if command -v ipfs &> /dev/null
    then
        echo "$hashes" | xe -j10x ipfs pin add {}
    else
        echo "$hashes" | xe -j10x curl -X POST http://ipfs:5001/api/v0/pin/add?arg={}
fi