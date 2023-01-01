FROM nixos/nix

RUN nix-channel --update

RUN nix-shell --run exit

ADD ./pin.sh /pin.sh
RUN chmod a+x /pin.sh

CMD nix-shell /pin.sh