FROM nixos/nix:2.16.1

# Get latest gildlab cli from main
RUN nix --extra-experimental-features "nix-command flakes" --print-build-logs profile install github:gildlab/gildlab-cli
RUN gildlab-cli --version

ADD . .
RUN chmod a+x /main.sh

CMD nix-shell /main.sh true