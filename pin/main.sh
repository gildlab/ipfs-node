#!/usr/bin/env nix-shell
#! nix-shell -i bash -p jq curl xe dig

set -Eeux

. pin.sh

main() {
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