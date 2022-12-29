{ pkgs ? import <nixpkgs> {} }:
let
    source-env = ''
      if [[ -f ".env" ]]
        then
          ${pkgs.dotenv-linter}/bin/dotenv-linter
          source .env
      fi
    '';

    required-vars = ["NGROK_AUTH" "NGROK_HOSTNAME" "NGROK_REGION"];

    ensure-var = var-name: ''
      echo "''${${var-name}}"
      if [ -z "''${${var-name}}" ];
      then
        read -p "Please set ${var-name}: " ${var-name}

        if [ -z "''${${var-name}}" ];
          then
            echo "Failed to set ${var-name}" >&2
            exit 1
        fi
      else
        echo "${var-name} is set."
      fi
    '';

    gl-docker-build = pkgs.writeShellScriptBin "gl-docker-build" ''
        ${pkgs.docker}/bin/docker build -f ./Dockerfile.ipfs -t gildlab/ipfs .
    '';

    gl-docker-run = pkgs.writeShellScriptBin "gl-docker-run" ''
      ${pkgs.docker}/bin/docker-compose up
    '';
in
pkgs.mkShell {
  # buildInputs is for dependencies you'd need "at run time",
  # were you to to use nix-build not nix-shell and build whatever you were working on
  buildInputs = [
    pkgs.dotenv-linter
    pkgs.docker
    gl-docker-build
  ];

  shellHook = ''
    ${source-env}
    ${builtins.concatStringsSep "" (map ensure-var required-vars)}
  '';
}