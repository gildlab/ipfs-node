FROM nixos/nix

RUN nix-channel --update

ADD ./pin.sh /pin.sh
RUN chmod a+x /pin.sh

CMD ["/root/.nix-profile/bin/nix-shell", "/pin.sh"]