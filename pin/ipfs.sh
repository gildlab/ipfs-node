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
