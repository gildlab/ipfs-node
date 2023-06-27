FROM nixos/nix

RUN nix-channel --update

RUN nix-shell -p bash jq curl xe dig --run exit

# Get latest gildlab cli from main
RUN nix-shell -p rustc cargo pkgconfig openssl --run 'cargo install --git https://github.com/gildlab/gildlab-cli --branch main && cargo clean'
ENV PATH="$PATH:$USER/.cargo/bin"

ADD . .
RUN chmod a+x /main.sh

CMD nix-shell /main.sh true