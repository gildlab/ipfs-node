FROM nixos/nix

RUN nix-channel --update

ADD ./default.nix default.nix

RUN nix-shell --run "exit"

CMD nix-shell --run "while true; do gl-pins; sleep 10; done"