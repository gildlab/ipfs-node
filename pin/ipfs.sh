#!/usr/bin/env nix-shell
#! nix-shell -i bash

set -Eeux

# detect the host of the service
ipfs_service_host() {
    if [ -z $( dig +short "${IPFS_HOST}" ) ]
        then
            echo "localhost"
        else
            echo "${IPFS_HOST}"
    fi
}

# determine if kubo is available direct
is_ipfs_running() {
    ipfs id &>/dev/null
}

ipfs_url() {
    echo "http://$( ipfs_service_host ):5001/api/v0/$1?arg=";
}

ipfs_curl_all() {
    local url_prefix=$( ipfs_url "$1" )
    sed 's#^#'"$url_prefix"'#g' <<< "$2" | xe -j10x curl -s -X POST
}

ipfs_dispatch() {
    if is_ipfs_running
        then
            $1 "$3"
        else
            $2 "$3"
    fi
}