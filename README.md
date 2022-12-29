# Gildlab IPFS node

## Installation

ONLY UBUNTU WITH SUDO IS SUPPORTED AT THIS TIME

### Install curl

This may or may not already be installed in ubuntu.

```
sudo apt-get update
sudo apt-get install curl -y
```

### Install nix

Install nix according to the instructions at https://nixos.org/download.html

At the time of writing the recommended multiuser script is:

```
$ sh <(curl -L https://nixos.org/nix/install) --daemon
```

If nix is installed correctly you should be able to check the version.

```
$ nix-shell --version
```

### Install docker engine

There are many ways to install docker https://docs.docker.com

On desktop OS you can install docker desktop but all you need is docker engine.

At the time of writing the autoinstall script for docker engine is:

```
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sh get-docker.sh
```

If docker is installed correctly you should be able to check the version.

```
$ docker --version
```

### Enter the nix shell for this repository

Once you have nix shell and docker installed you can enter the nix shell with all the commands in this repository.

```
$ nix-shell https://github.com/gildlab/ipfs-node/archive/main.tar.gz?`date -Iseconds`
```

The shell requires that some environment variables are set.

Ngrok auth token can be found: https://dashboard.ngrok.com/get-started/your-authtoken

Ngrok domains can be setup: https://dashboard.ngrok.com/cloud-edge/domains

These values can be changed later by modifying

#### Available commands

Inside the nix shell the following commands are available.

`nix-shell --run gl-docker-build`: Builds and tags all docker files.

`nix-shell --run gl-docker-run`: Uses docker compose to bring all dockers up.

`nix-shell --run gl-config-edit`: Opens the .env file in nano text editor.