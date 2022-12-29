# Gildlab IPFS node

## Installation

ONLY UBUNTU WITH SUDO IS SUPPORTED AT THIS TIME

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