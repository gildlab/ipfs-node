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