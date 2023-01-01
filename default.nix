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
      export GILDLAB_IPFS_NODE_BASE_PATH=${path}
      mkdir -p ${path}
      mkdir -p ${path}/volumes/ipfs/data/ipfs
      mkdir -p ${path}/volumes/ipfs/export
      mkdir -p ${path}/volumes/nginx
      touch ${path}/.env
    '';

    source-env = ''
      if [[ -f "${path}/.env" ]]
        then
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
            echo "${var-name}=\"''${${var-name}}\"" >> ${path}/.env
        fi
      fi
    '';

    temp-main = ''
        dir=$(mktemp -d)
        cd $dir
        wget ${tarball-url}
        tar --strip-components=1 -zxvf main.tar.gz
    '';

    gl-docker-build = pkgs.writeShellScriptBin "gl-docker-build" ''
    (
        repo=gildlab/ipfs-node

        ${pkgs.docker}/bin/docker build -t ''${repo}:ipfs ./ipfs
        ${pkgs.docker}/bin/docker push ''${repo}:ipfs

        ${pkgs.docker}/bin/docker build -t ''${repo}:nginx ./nginx
        ${pkgs.docker}/bin/docker push ''${repo}:nginx

        ${pkgs.docker}/bin/docker build -t ''${repo}:ngrok ./ngrok
        ${pkgs.docker}/bin/docker push ''${repo}:ngrok

        ${pkgs.docker}/bin/docker build -t ''${repo}:pin ./pin
        ${pkgs.docker}/bin/docker push ''${repo}:pin
    )
    '';

    cp-firewall-apps = ''
      sudo cp ufw/gildlab /etc/ufw/applications.d/gildlab
    '';

    gl-enable-firewall = pkgs.writeShellScriptBin "gl-enable-firewall" ''
      ${cp-firewall-apps}
      sudo ufw enable
      sudo ufw allow "gildlab-ipfs"
      sudo ufw allow "gildlab-nginx"
    '';

    gl-disable-firewall = pkgs.writeShellScriptBin "gl-disable-firewall" ''
      ${cp-firewall-apps}
      sudo ufw delete allow "gildlab-ipfs"
      sudo ufw delete allow "gildlab-nginx"
    '';

    gl-docker-run = pkgs.writeShellScriptBin "gl-docker-run" ''
      ${temp-main}
      ${(map ensure-var required-vars)}
      ${pkgs.docker-compose}/bin/docker-compose down

      ${gl-enable-firewall}/bin/gl-enable-firewall
      sudo rm -f ${path}/volumes/ipfs/data/ipfs/repo.lock ${path}/volumes/ipfs/data/ipfs/datastore/LOCK

      ${pkgs.docker}/bin/docker network prune -f

      ${pkgs.docker-compose}/bin/docker-compose up -d
    '';

    gl-docker-logs = pkgs.writeShellScriptBin "gl-docker-logs" ''
      ${temp-main}
      ${pkgs.docker-compose}/bin/docker-compose logs
    '';

    images = ["gildlab/ipfs-node:ipfs" "gildlab/ipfs-node:nginx" "gildlab/ipfs-node:ngrok"];
    docker-stop = image: ''
      ${pkgs.docker}/bin/docker rm $(${pkgs.docker}/bin/docker stop $(${pkgs.docker}/bin/docker ps -a -q --filter "ancestor=${image}"))
    '';
    gl-docker-stop = pkgs.writeShellScriptBin "gl-docker-stop" ''
      ${builtins.concatStringsSep "" (map docker-stop images)}
    '';

    gl-config-edit = pkgs.writeShellScriptBin "gl-config-edit" ''
      ${builtins.concatStringsSep "" (map ensure-var required-vars)}
      ${pkgs.nano}/bin/nano ${path}/.env
      ${pkgs.dotenv-linter}/bin/dotenv-linter ${path}/.env
      ${source-env}
    '';

    sg-url = "https://api.thegraph.com/subgraphs/name/gild-lab/offchainassetvault";
    deployer = "0x8058ad7c22fdc8788fe4cb1dac15d6e976127324";

    sg-query = "{ \"query\": \"{ deployer(id: \\\"${deployer}\\\"){ hashes(first:100, skip: 0, orderBy:timestamp, orderDirection: asc){ hash } } }\" }";

    sg-jq = ".data.deployer.hashes[].hash | select(startswith(\"Qm\"))";

    gl-pins = pkgs.writeShellScriptBin "gl-pins" ''
      ${pkgs.curl}/bin/curl -X POST ${sg-url} -d '${sg-query}' \
      | ${pkgs.jq}/bin/jq -r '${sg-jq}' \
      | while read pin; \
          do \
            echo "$pin"; \
            curl -X POST "http://ipfs:5001/api/v0/pin/add/$pin"; \
          done;
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
    gl-docker-build
    gl-docker-run
    gl-docker-stop
    gl-config-edit
    gl-enable-firewall
    gl-disable-firewall
    gl-docker-logs
    gl-pins
  ];

  shellHook = ''
    ${ensure-home}
    ${source-env}
  '';
}