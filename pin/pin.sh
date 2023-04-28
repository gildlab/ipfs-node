#!/usr/bin/env nix-shell
#! nix-shell -i bash -p jq curl xe dig sed

set -Eeux

. ipfs.sh

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
    # use gildlab-cli instead of fetch hashes as it supports pagination
    # @todo replace all with cli
    pin_add "$( gildlab-cli pins )"
}