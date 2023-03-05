{ pkgs ? import
    (builtins.fetchTarball {
      name = "nixos-unstable-2022-12-18";
      url = "https://github.com/nixos/nixpkgs/archive/9bf79ea2f90a7b76a0670b6ea14aa502975ad0bf.tar.gz";
      sha256 = "sha256:048znm5k0ny2pbp08myj4qf352zdg19ls45m0750jwryh3j3aacv";
    })
    { } }:
let
    tarball-url = "https://github.com/gildlab/ipfs-node/archive/main.tar.gz";
    path = "$HOME/.config/gildlab/ipfs-node";
    ensure-home = ''
      set -u
      export GILDLAB_IPFS_NODE_BASE_PATH=${path}
      mkdir -p ${path}

      mkdir -p ${path}/volumes/ipfs/data/ipfs
      mkdir -p ${path}/volumes/ipfs/export
      mkdir -p ${path}/volumes/pin
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
        else
          touch ${path}/.env
      fi
    '';

    # set some defaults if not set
    default-env = ''
      : "''${GILDLAB_IPFS_NODE_CHANNEL:=main}"
    '';

    ngrok-required-vars = ["GILDLAB_IPFS_NODE_API_HOSTNAME" "GILDLAB_IPFS_NODE_TCP_HOSTNAME" "GILDLAB_IPFS_NODE_TCP_PORT" "NGROK_AUTHTOKEN" "NGROK_REGION"];

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

    ensure-ngrok-required-vars = ''
      ${builtins.concatStringsSep "" (map ensure-var ngrok-required-vars)}
      ${source-env}
    '';

    container-names = ["gl_ipfs" "gl_nginx" "gl_pin" "gl_ngrok_ipfs" "gl_ngrok_nginx"];
    down-container = container: ''
      ${pkgs.docker}/bin/docker stop ${container}
      ${pkgs.docker}/bin/docker rm ${container}
    '';
    down-containers = builtins.concatStringsSep "" (map down-container container-names);

    gl-docker-start = pkgs.writeShellScriptBin "gl-docker-start" ''
      set -u
      ${ensure-ngrok-required-vars}
      ${temp-main}
      ${down-containers}

      sudo rm -f ${path}/volumes/ipfs/data/ipfs/repo.lock ${path}/volumes/ipfs/data/ipfs/datastore/LOCK

      ${pkgs.docker}/bin/docker network prune -f

      ${pkgs.docker-compose}/bin/docker-compose pull
      ${pkgs.docker-compose}/bin/docker-compose up -d
    '';

    gl-docker-compose = pkgs.writeShellScriptBin "gl-docker-compose" ''
      set -u
      ${ensure-ngrok-required-vars}
      ${temp-main}
      ${pkgs.docker-compose}/bin/docker-compose "$@"
    '';

    gl-docker-logs = pkgs.writeShellScriptBin "gl-docker-logs" ''
      ${temp-main}
      ${pkgs.docker-compose}/bin/docker-compose logs
    '';

    gl-config-edit = pkgs.writeShellScriptBin "gl-config-edit" ''
      ${builtins.concatStringsSep "" (map ensure-var ngrok-required-vars)}
      ${pkgs.nano}/bin/nano ${path}/.env
      ${pkgs.dotenv-linter}/bin/dotenv-linter ${path}/.env
      ${source-env}
    '';

    gl-basicauth-edit = pkgs.writeShellScriptBin "gl-basicauth-edit" ''
      mkdir -p ${path}/volumes/nginx
      ${pkgs.nano}/bin/nano ${path}/volumes/nginx/.htpasswd
    '';

    gl-peerlist-edit = pkgs.writeShellScriptBin "gl-peerlist-edit" ''
      mkdir -p ${path}/volumes/pin
      sudo ${pkgs.nano}/bin/nano ${path}/volumes/pin/peerlist
    '';

    gl-peerlist-show = pkgs.writeShellScriptBin "gl-peerlist-show" ''
      sudo cat ${path}/volumes/pin/peerlist
    '';

    gl-peerlist-export = pkgs.writeShellScriptBin "gl-peerlist-export" ''
      sudo cat ${path}/volumes/pin/peerlist | ix
    '';

    gl-peerlist-import = pkgs.writeShellScriptBin "gl-peerlist-import" ''
      sudo curl "$@" -o ${path}/volumes/pin/peerlist
    '';

    # Provides a fresh ipfs setup by moving the current one somewhere that
    # ipfs doesn't know to look. Not subtle.
    gl-fresh-ipfs = pkgs.writeShellScriptBin "gl-fresh-ipfs" ''
    set -u
    mv ''${GILDLAB_IPFS_NODE_BASE_PATH}/volumes/ipfs ''${GILDLAB_IPFS_NODE_BASE_PATH}/volumes/ipfs.bak.$(date +%s )
    '';

    gl-docker-health = pkgs.writeShellScriptBin "gl-docker-health" ''
      docker inspect --format "{{json .State.Health }}" "$@" | jq
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
    pkgs.ix
    pkgs.curl
    pkgs.jq
    gl-docker-start
    gl-config-edit
    gl-docker-logs
    gl-fresh-ipfs
    gl-basicauth-edit
    gl-peerlist-edit
    gl-peerlist-show
    gl-peerlist-import
    gl-peerlist-export
    gl-docker-compose
    gl-docker-health
  ];

  shellHook = ''
    ${temp-main}
    ${ensure-home}
    ${source-env}
    ${default-env}
  '';
}
