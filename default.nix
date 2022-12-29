{ pkgs ? import <nixpkgs> {} }:
let
    source-env = ''
      if [[ -f ".env" ]]
        then
          source .env
      fi
    '';

    gl-reset-env = pkgs.writeShellScriptBin "gl-reset-env" ''
    rm .env
    ${ensure-env}
    '';

    required-vars = ["NGROK_AUTH" "NGROK_HOSTNAME" "NGROK_REGION"];

    ensure-var = var-name: ''
      echo "''${${var-name}}"
      if [ -z "''${${var-name}}" ];
      then
        read -p "Please set ${var-name}: " ${var-name}
      else
        echo "${var-name} is set"
      fi
    '';

    gl-doctor = pkgs.writeShellScriptBin "gl-doctor" ''
        ${ensure-env}

        ${pkgs.dotenv-linter}/bin/dotenv-linter

        ${builtins.concatStringsSep "" (map ensure-var required-vars)}
    '';

    gl-docker-build = pkgs.writeShellScriptBin "gl-docker-build" ''
        ${pkgs.docker}/bin/docker build -f ./Dockerfile.ipfs -t gildlab/ipfs .
    '';
in
pkgs.mkShell {
  # buildInputs is for dependencies you'd need "at run time",
  # were you to to use nix-build not nix-shell and build whatever you were working on
  buildInputs = [
    pkgs.dotenv-linter
    pkgs.nano
    gl-reset-env
    gl-doctor
    gl-docker-build
  ];

  shellHook = ''
    ${source-env}
    ${builtins.concatStringsSep "" (map ensure-var required-vars)}
  '';
}