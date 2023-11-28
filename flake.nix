{
  description = "Flake for development workflows.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/ec750fd01963ab6b20ee1f0cb488754e8036d89d";
    gildlab.url = "github:gildlab/gildlab.cli/b45f0e1b2a783f0581c3e8cccd1b1756b49d1376";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, gildlab, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        path = "$HOME/.config/gildlab/ipfs-node";
        ensure-home = ''
        set -u
        export GILDLAB_IPFS_NODE_BASE_PATH=${path}
        mkdir -p ${path}

        mkdir -p ${path}/volumes/ipfs/data/ipfs
        mkdir -p ${path}/volumes/ipfs/export
        mkdir -p ${path}/volumes/pin

        mkdir -p ${path}/volumes/nginx
        touch ${path}/.env
        '';

      in rec {
        packages = rec {

        };

        devShell = pkgs.mkShell rec {
            buildInputs = [
                gildlab.defaultPackage.${system}
                pkgs.apacheHttpd
            ];

            shellHook = ''
            ${ensure-home}
            source ${path}/.env
            '';
        };
      }
    );
}