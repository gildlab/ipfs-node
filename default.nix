{ pkgs ? import
    (builtins.fetchTarball {
      name = "nixos-unstable-2022-12-18";
      url = "https://github.com/nixos/nixpkgs/archive/b65120b662a663f997ddc795c3e42fe9218864c4.tar.gz";
      sha256 = "sha256:1xa1fif440zhlhc5s3pk9mkprkzvk0rcgif8k4mscbcl6c8sgqw0";
    })
    { } }:
let
    path = "$HOME/.config/gildlab/ipfs-node";
    ensure-home = ''
      export GILDLAB_IPFS_NODE_BASE_PATH=${path}
      mkdir -p ${path}
      mkdir -p ${path}/volumes/ipfs/data/ipfs
      mkdir -p ${path}/volumes/ipfs/export
      mkdir -p ${path}/volumes/nginx
    '';

    source-env = ''
      if [[ -f "${path}/.env" ]]
        then
          ${pkgs.dotenv-linter}/bin/dotenv-linter ${path}/.env
          set -o allexport
          source ${path}/.env
          set +o allexport
        else
          touch ${path}/.env
      fi
    '';

    required-vars = ["NGROK_AUTH" "NGROK_HOSTNAME" "NGROK_REGION"];

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
        dir=$(mktemp -d)
        cd $dir
        wget https://github.com/gildlab/ipfs-node/archive/main.tar.gz
        tar --strip-components=1 -zxvf main.tar.gz
    '';

    gl-docker-build = pkgs.writeShellScriptBin "gl-docker-build" ''
    (
        ${temp-main}
        tag=gildlab/ipfs-node:ipfs
        ${pkgs.docker}/bin/docker build -f ./Dockerfile.ipfs -t ''${tag} .
        ${pkgs.docker}/bin/docker push ''${tag}
    )
    '';

    gl-docker-run = pkgs.writeShellScriptBin "gl-docker-run" ''
      ${temp-main}
      ${pkgs.docker-compose}/bin/docker-compose up
    '';

    gl-config-edit = pkgs.writeShellScriptBin "gl-config-edit" ''
      ${pkgs.nano}/bin/nano ${path}/.env
    '';
in
pkgs.mkShell {
  # buildInputs is for dependencies you'd need "at run time",
  # were you to to use nix-build not nix-shell and build whatever you were working on
  buildInputs = [
    pkgs.dotenv-linter
    pkgs.docker
    pkgs.nano
    pkgs.wget
    # ipfs
    pkgs.kubo
    pkgs.ix
    gl-docker-build
    gl-docker-run
    gl-config-edit
  ];

  shellHook = ''
    ${ensure-home}
    ${source-env}
    ${builtins.concatStringsSep "" (map ensure-var required-vars)}
  '';
}