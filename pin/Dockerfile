FROM nixos/nix

RUN nix-channel --update

ADD ./pin.sh /pin.sh
RUN chmod a+x /pin.sh

CMD ["/nix/var/nix/profiles/default/bin/nix-shell", "/pin.sh"]