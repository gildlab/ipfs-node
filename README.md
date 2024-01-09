# Gildlab IPFS node

## Installation

### Get an Ubuntu Server USB

ONLY UBUNTU SERVER WITH SUDO IS SUPPORTED AT THIS TIME

The assumption is that:

- This is being installed on a dedicated machine
- With a wired (not wifi) network connection and a static IP assigned by the ISP
- That can be wiped and rebuilt on short notice
- With the intent to keep the system as simple and low maintenance as possible

Download Ubuntu Server (not desktop) from https://ubuntu.com/download/server

Get an LTS (long term support) version.

This guide was last reviewed under 22.04.2

Download Balena Etcher https://etcher.balena.io/

On linux the Balena Etcher is an AppImage so https://github.com/TheAssassin/AppImageLauncher
might help to run it.

### Install Ubuntu Server

Boot the device with the Ubuntu Server USB inserted, it should offer installing
Ubuntu.

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

The nix shell might not be immediately visible in the shell that you installed
it from. You can enter a new shell.

```
$ exec $SHELL
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

To verify that the current user can run docker commands without root access.

```
$ docker run hello-world
```

If this doesn't work then run the post installation steps https://docs.docker.com/engine/install/linux-postinstall/

```
$ sudo groupadd docker
$ sudo usermod -aG docker $USER
```

You may need to restart the machine for these changes to take effect.

### Enter the nix shell for this repository

Once you have nix and docker installed you can run nix shell commands from this repo.

First clone the repo from github, then run `nix-shell` from inside it.

```
git clone git@github.com:gildlab/ipfs-node.git
cd ipfs-node
nix-shell
```

Now you should be inside a nix shell, which allows you to run the `gl-*` commands.

#### Setup config

Run `gl-config-edit` in nix shell to setup config for your environment.

`GILDLAB_IPFS_NODE_CHANNEL` : Set the channel (github branch) to either `main` or `develop`. Default is `main` if not set.

The config file is `.env` style, using the `export` keyword for variables.

E.g. Your config file should look like:

```
export GILDLAB_IPFS_NODE_CHANNEL=develop
```

#### (Re)start the docker

Run `gl-docker-start` in nix shell to (re)boot all the boxes.

This needs to be run whenever config/peerlist/etc. changes so that the changes take effect.

## Commands

### New password for ipfs node

1. Enter `nix develop`
2. htpasswd -nbB -C 10 <username> <password>

This will provide hashed (bcrypt) version of the password with username in a
format that is compatible with nginx.

Note that this uses `nix develop` rather than `nix-shell` as it uses the flake
instead of the `default.nix` file. The nix shell way of doing things is
deprecated, so things will be moved to `nix develop` over time.