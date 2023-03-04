FROM nixos/nix

RUN nix-channel --update

RUN nix-shell -p bash jq curl xe dig --run exit

ADD . .
RUN chmod a+x /main.sh

CMD nix-shell /main.sh true