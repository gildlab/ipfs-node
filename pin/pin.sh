#!/usr/bin/env nix-shell
#! nix-shell -i bash -p jq curl xe dig sed

set -Eeux

. ipfs.sh

# query for hashes from the subgraph
build_query () {
    local ids=('0x8058ad7c22fdc8788fe4cb1dac15d6e976127324' '0xc0D477556c25C9d67E1f57245C7453DA776B51cf');
    # Build a lowercased json array from ids bash array
    local jsonids=$( jq -c -n '$ARGS.positional' --args "${ids[@],,}")
    local query=$( cat << "QUERY"
        query($ids: [String!]) {
            hashes(
              first:100
              skip: 0
              orderBy:timestamp
              orderDirection: desc
              where: {offchainAssetReceiptVaultDeployer_in: $ids}
            ) {
                hash
            }
        }
QUERY
    );
    local payload=$( cat << "PAYLOAD"
        {
            query: $query,
            variables: {
                ids: $ids
            }
        }
PAYLOAD
    );
    jq -n --arg query "$query" --arg ids $jsonids "$payload";
}

# fetch hashes from subgraph
fetch_hashes() {
    local url='https://api.thegraph.com/subgraphs/name/gild-lab/offchainassetvault'
    local jq_selector='.data.hashes[].hash | select(startswith("Qm"))';

    curl -X POST -d "$( build_query )" $url | jq -r "$jq_selector";
}

# pin using kubo directly
pin_direct() {
    echo "$1" | xe -j10x ipfs pin add
}

# pin using a service
pin_service() {
    ipfs_curl_all "pin/add" "$1"
}

pin_add() {
    ipfs_dispatch pin_direct pin_service "$1"
}

# pin the hashes to the ipfs node
main_pin() {
    pin_add "$( fetch_hashes )"
}