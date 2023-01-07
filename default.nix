{ pkgs ? import
    (builtins.fetchTarball {
      name = "nixos-unstable-2022-12-18";
      url = "https://github.com/nixos/nixpkgs/archive/b65120b662a663f997ddc795c3e42fe9218864c4.tar.gz";
      sha256 = "sha256:1xa1fif440zhlhc5s3pk9mkprkzvk0rcgif8k4mscbcl6c8sgqw0";
    })
    { } }:
let
    tarball-url = "https://github.com/gildlab/ipfs-node/archive/main.tar.gz";
    path = "$HOME/.config/gildlab/ipfs-node";
    ensure-home = ''
      set -ux
      export GILDLAB_IPFS_NODE_BASE_PATH=${path}
      mkdir -p ${path}

      mkdir -p ${path}/volumes/ipfs/data/ipfs
      mkdir -p ${path}/volumes/ipfs/export
      sudo touch ${path}/volumes/pin/peerlist

      mkdir -p ${path}/volumes/nginx
      touch ${path}/.env
    '';

    # The +x is to avoid dumping environment vars to logs
    source-env = ''
      if [[ -f "${path}/.env" ]]
        then
          set +x
          set -o allexport
          source ${path}/.env
          set +o allexport
          set -x
        else
          touch ${path}/.env
      fi
    '';

    required-vars = ["NGROK_AUTHTOKEN" "NGROK_EDGE" "NGROK_EDGE_HOSTNAME" "NGROK_EDGE_PORT" "NGROK_HOSTNAME" "NGROK_REGION"];

    ensure-var = var-name: ''
      if [ -z "''${${var-name}}" ];
      then
        read -p "Please set ${var-name}: " ${var-name}

        if [ -z "''${${var-name}}" ];
          then
            echo "Failed to set ${var-name}" >&2
            exit 1
          else
            echo "${var-name}=''${${var-name}}" >> ${path}/.env
        fi
      fi
    '';

    temp-main = ''
      if [ ! -f ./IPFS_NODE ];
        then
          dir=$(mktemp -d);
          cd $dir;
          wget ${tarball-url};
          tar --strip-components=1 -zxvf main.tar.gz;
      fi
    '';

    ensure-required-vars = ''
      ${builtins.concatStringsSep "" (map ensure-var required-vars)}
      ${source-env}
    '';

    gl-docker-start = pkgs.writeShellScriptBin "gl-docker-start" ''
      set -ux
      ${ensure-required-vars}
      ${temp-main}
      ${pkgs.docker-compose}/bin/docker-compose down --remove-orphans

      sudo rm -f ${path}/volumes/ipfs/data/ipfs/repo.lock ${path}/volumes/ipfs/data/ipfs/datastore/LOCK

      ${pkgs.docker}/bin/docker network prune -f

      ${pkgs.docker-compose}/bin/docker-compose pull
      ${pkgs.docker-compose}/bin/docker-compose up -d
    '';

    gl-docker-compose = pkgs.writeShellScriptBin "gl-docker-compose" ''
      set -ux
      ${ensure-required-vars}
      ${temp-main}
      ${pkgs.docker-compose}/bin/docker-compose "$@"
    '';

    gl-docker-logs = pkgs.writeShellScriptBin "gl-docker-logs" ''
      ${temp-main}
      ${pkgs.docker-compose}/bin/docker-compose logs
    '';

    gl-config-edit = pkgs.writeShellScriptBin "gl-config-edit" ''
      ${builtins.concatStringsSep "" (map ensure-var required-vars)}
      ${pkgs.nano}/bin/nano ${path}/.env
      ${pkgs.dotenv-linter}/bin/dotenv-linter ${path}/.env
      ${source-env}
    '';

    gl-peerlist-edit = pkgs.writeShellScriptBin "gl-peerlist-edit" ''
      mkdir -p ${path}/volumes/pin
      sudo ${pkgs.nano}/bin/nano ${path}/volumes/pin/peerlist
    '';

    gl-peerlist-show = pkgs.writeShellScriptBin "gl-peerlist-show" ''
      sudo cat ${path}/volumes/pin/peerlist
    '';

    gl-fresh-ipfs = pkgs.writeShellScriptBin "gl-fresh-ipfs" ''
    set -ux
    mv ''${GILDLAB_IPFS_NODE_BASE_PATH}/volumes/ipfs ''${GILDLAB_IPFS_NODE_BASE_PATH}/volumes/ipfs.bak.$(date +%s )
    '';

in
pkgs.mkShell {
  # buildInputs is for dependencies you'd need "at run time",
  # were you to to use nix-build not nix-shell and build whatever you were working on
  buildInputs = [
    pkgs.dotenv-linter
    pkgs.docker
    pkgs.docker-compose
    pkgs.nano
    pkgs.wget
    # ipfs
    pkgs.kubo
    pkgs.ix
    pkgs.curl
    pkgs.jq
    gl-docker-start
    gl-config-edit
    gl-docker-logs
    gl-fresh-ipfs
    gl-peerlist-edit
    gl-peerlist-show
    gl-docker-compose
  ];

  shellHook = ''
    ${ensure-home}
    ${source-env}
  '';
}
