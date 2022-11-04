#!/bin/bash

RED="\e31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

goPath=`which go`

if [ -n "$goPath" ]
then
    echo  "go found: $goPath" 
else
    echo "installing go"
    'curl https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh | bash '
    echo "go installed"
    echo 'go version'
fi

ipfsPath=`which ipfs`

if [ -n "$ipfsPath" ]
then 
    echo "ipfs found: $ipfsPath"
else
    echo "installing go-ipfs"
    `wget https://dist.ipfs.tech/kubo/v0.16.0/kubo_v0.16.0_linux-amd64.tar.gz`
    `tar -xvzf kubo_v0.16.0_linux-amd64.tar.gz`
    `cd kubo && sudo bash install.sh`

    echo "go-ipfs installed."
    echo `ipfs --version`
fi

user=`whoami`

source /home/$user/.bashrc

echo "initializing ipfs"
ipfs init

echo -e "${GREEN}start ngrok endpoint with : /home/erigon-node/ngrok start --config=/home/erigon-node/server-scripts/ngrok/config.yml --all${ENDCOLOR}" 

echo "To run ipfs on boot please run ${GREEN} sudo systemctl enable ipfs ${ENDCOLOR}"


