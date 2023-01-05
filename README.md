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
$ docker run hellow-world
```

If this doesn't work then run the post installation steps https://docs.docker.com/engine/install/linux-postinstall/

```
$ sudo groupadd docker
$ sudo usermod -aG docker $USER
```

You may need to restart the machine for these changes to take effect.

To push docker boxes that you build you will need to log into docker hub.

```
$ docker login
```

### Enter the nix shell for this repository

Once you have nix and docker installed you can run nix shell commands straight from github.

```
nix-shell https://abc.gildlab.xyz?$RANDOM --run <command>
```

Where `<command>` is whatever command you want to run.

#### Setup config

Run `gl-config-edit` in nix shell to setup config for your environment.
The required configuration will be prompted if not set and then you can edit them all in the editor.

#### Setup peerlist

Run `gl-peerlist-edit` in nix shell to setup the peerlist.
Each peer is simply a newline.

For ngrok peers each line will look like:

```
/dns/1.tcp.ngrok.io/tcp/<port>/p2p/<ipfs id>
```

Where your `port` can be found on the ngrok dashboard and your own `ipfs id` can be found by running `docker exec gl_ipfs ipfs id`.

Each peer on the same setup can run the same commands to tell you their ipfs id and ngrok tcp port.

You can also share peerlists in telegram, etc.

#### (Re)start the docker

Run `gl-docker-start` in nix shell to (re)boot all the boxes.

This needs to be run whenever config/peerlist/etc. changes so that the changes take effect.