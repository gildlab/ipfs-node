#!/usr/bin/env nix-shell
#! nix-shell -i bash

set -Eeux

. peering.sh
. pin.sh

main() {
    main_peering
    main_pin
}

# main loop
loop() {
    while true
        do
            main
            sleep 10
        done
}

if $1
    then loop
    else main
fi