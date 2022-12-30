FROM nixos/nix

RUN nix-channel --update

ADD ./default.nix default.nix

RUN nix-shell --run "exit"