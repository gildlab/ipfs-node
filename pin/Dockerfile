FROM nixos/nix

RUN nix-channel --update

RUN nix-shell -p bash jq curl xe --run exit

ADD ./pin.sh /pin.sh
RUN chmod a+x /pin.sh

HEALTHCHECK --interval=30s --timeout=5m --retries=1 CMD nix-shell /pin.sh