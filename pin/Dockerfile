FROM nixos/nix

RUN nix-channel --update

ADD ./pin.sh pin.sh

CMD ./pin.sh