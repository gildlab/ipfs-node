{ pkgs ? import <nixpkgs> {} }:
let
    gl-doctor = pkgs.writeShellScriptBin "gl-doctor" ''
        ${pkgs.dotenv-linter}/bin/dotenv-linter

        if [ -z "$NGROK_AUTH" ]
        then
            echo "\$NGROK_AUTH is empty"
        else
            echo "\$NGROK_AUTH is something"
        fi
    '';

    gl-docker-build = pkgs.writeShellScriptBin "gl-docker-build" ''
        ${pkgs.docker}/bin/docker build -f ./Dockerfile.ipfs -t gildlab/ipfs .
    '';
in
pkgs.mkShell {
  # buildInputs is for dependencies you'd need "at run time",
  # were you to to use nix-build not nix-shell and build whatever you were working on
  buildInputs = [
    pkgs.docker-client
    pkgs.dotenv-linter
    gl-doctor
    gl-docker-build
  ];

  shellHook = ''
    source .env
  '';
}