FROM nixos/nix

RUN nix-channel --update

ADD ./pin.sh /pin.sh
RUN chmod a+x /pin.sh

HEALTHCHECK --interval=10s --timeout=5m --retries=1 CMD nix-shell /pin.sh