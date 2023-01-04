#!/usr/bin/env nix-shell
#! nix-shell -i bash -p bash jq curl xe dig

set -Eeuxo pipefail

# get the hashes from the subgraph

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

# pin the hashes to the ipfs node

# detect if we are the machine running ipfs kubo itself
if command -v ipfs &> /dev/null
    then
        echo "$hashes" | xe -j10x ipfs pin add {}
    else
        # detect if we're the docker host or guest to try to curl the machine that is running kubo
        host=$( if [ -z $( dig +short gl_ipfs ) ]; then echo "localhost"; else echo "gl_ipfs"; fi )
        url="http://$host:5001/api/v0/pin/add?arg="
        sed 's#^#'"$url"'#g' <<< "$hashes" | xe -j10x curl --fail -v -X POST
fi