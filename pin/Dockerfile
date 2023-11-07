FROM nixos/nix:2.18.1

# Get latest gildlab cli from main
RUN nix --extra-experimental-features "nix-command flakes" --print-build-logs profile install github:gildlab/gildlab.cli/b45f0e1b2a783f0581c3e8cccd1b1756b49d1376 && nix-collect-garbage -d
RUN gildlab-cli --version

ADD . .
RUN chmod a+x /main.sh

CMD nix-shell /main.sh true