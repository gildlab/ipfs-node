FROM nixos/nix:2.16.1

RUN nix-channel --update

RUN nix-shell -p bash jq curl xe dig rustc cargo pkgconfig openssl --run exit

# Get latest gildlab cli from main
RUN nix profile install github:gildlab/gildlab-cli
RUN gildlab-cli --version

ADD . .
RUN chmod a+x /main.sh

CMD nix-shell /main.sh true