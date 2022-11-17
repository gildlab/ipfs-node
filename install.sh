#!/bin/bash
source .env

SCRIPTDIR=`cd "$(dirname "$0")" && pwd`

## Checking if root else
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

## CHECKING ENV VARIABLES
if [[ ( -z "$SERVICE_USER" ) || ( -z "$NGROK_DOMAIN" ) || ( -z "$NGROK_AUTH_TOKEN" ) || ( -z "$NGROK_API_KEY" ) ]]; then
  echo "Environment variables not set"
  exit
fi

############################### Initializing Global Variables
## Building ipfs.service file
`cp ipfs/ipfs.service.template /tmp/ipfs.service`
`sed -i -e 's/SERVICE_USER/'"$SERVICE_USER"'/g' /tmp/ipfs.service`

## Building ngrok.service file
`cp ngrok/ngrok.service.template /tmp/ngrok.service`
`sed -i -e 's/SERVICE_USER/'"$SERVICE_USER"'/g' /tmp/ngrok.service`

## Building ngrok config file
`cp ngrok/config.yml.template /tmp/config.yml`
`sed -i -e 's/NGROK_DOMAIN/'"$NGROK_DOMAIN"'/g' /tmp/config.yml`
`sed -i -e 's/NGROK_AUTHTOKEN/'"$NGROK_AUTH_TOKEN"'/g' /tmp/config.yml`

## Copy config to ~/.config/ngrok/config.yml 
`mkdir -p /home/$SERVICE_USER/.config/ngrok/ && cp /tmp/config.yml /home/$SERVICE_USER/.config/ngrok/config.yml`

################################ Installing GO

if [ ! -f /usr/local/go/bin/go ]; then
    echo -e "installing go"
    # `sudo wget https://golang.org/dl/go1.15.5.linux-amd64.tar.gz`
    `sudo tar -C /usr/local -xzf go1.15.5.linux-amd64.tar.gz`
    `echo "export PATH=$PATH:/usr/local/go/bin" >> /home/$SERVICE_USER/.bashrc`
    `source /home/$SERVICE_USER/.bashrc`
    /usr/local/go/bin/go version
else
    echo "GO FOUND, VERSION = "
    /usr/local/go/bin/go version
fi

################################ Installing IPFS
ipfsPath=`which ipfs`

if [ -n "$ipfsPath" ]
then 
    echo -e "ipfs found: $ipfsPath "
else
    echo -e "installing go-ipfs"
    `wget https://dist.ipfs.tech/kubo/v0.16.0/kubo_v0.16.0_linux-amd64.tar.gz`
    `tar -xvzf kubo_v0.16.0_linux-amd64.tar.gz`
    `cd kubo && sudo bash install.sh`

    echo -e "go-ipfs installed."
    echo `ipfs --version`
    source /home/$SERVICE_USER/.bashrc

    echo -e "initializing ipfs"
    ipfs init
   
fi

sudo apt install jq -y
## ipfs api setup
`cat <<< $(jq '.API.HTTPHeaders = { "Access-Control-Allow-Methods": [ "PUT", "GET", "POST" ], "Access-Control-Allow-Origin": [ "*" ] }' /home/$SERVICE_USER/.ipfs/config) > /home/$SERVICE_USER/.ipfs/config`

## Setting up ipfs service
`cp /tmp/ipfs.service /etc/systemd/system/ipfs.service`
`sudo systemctl daemon-reload`
`sudo systemctl start ipfs`
`sudo systemctl enable ipfs`

################################ Installing NGINX
nginxPath=`which nginx`

if [ -n "$nginxPath" ]
then 
    echo -e "nginx found: $nginxPath"
else
    echo "installing nginx"
    `sudo apt -y install nginx`
    echo "nginx installed and running."
fi
## Copying nginx config and restarting
`sudo cp  nginx/default /etc/nginx/sites-available/default`
`sudo systemctl daemon-reload`
`sudo service nginx restart`

################################ Installing NGROK
ngrokPath=`which ngrok`

if [ -n "$ngrokPath" ]
then 
    echo "ngrok found: $ngrokPath"
else
    echo "installing ngrok"
    curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list && sudo apt -y update && sudo apt -y install ngrok
    echo "ngrok installed"
fi


## Setting up ngrok service
`cp /tmp/ngrok.service /etc/systemd/system/ngrok.service`
`sudo systemctl daemon-reload`
`sudo systemctl start ngrok`
`sudo systemctl enable ngrok`