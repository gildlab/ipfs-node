#!/usr/bin/env nix-shell
#! nix-shell -i bash

set -Eeux

get_peers() {
    cat peerlist
}

main_peering() {
    get_peers
}