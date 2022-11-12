#!/bin/bash

############################### Initializing Global Variables
## ngrok auth token
echo "Enter the USERNAME from which you want to run the services : "
read serviceUser

echo "Enter ngrok auth token ? "
read ngrokAuthToken

echo "Enter ngrok domain ? "
read ngrokDomain

## Building ipfs.service file
`cp ipfs/ipfs.service.template ipfs/ipfs.service`
`sed -i -e 's/SERVICE_USER/'"$serviceUser"'/g' ipfs/ipfs.service`

## Building ngrok.service file
`cp ngrok/ngrok.service.template ngrok/ngrok.service`
`sed -i -e 's/SERVICE_USER/'"$serviceUser"'/g' ngrok/ngrok.service`

## Building ngrok config file
`cp ngrok/config.yml.template ngrok/config.yml`
`sed -i -e 's/NGROK_DOMAIN/'"$ngrokDomain"'/g' ngrok/config.yml`
`sed -i -e 's/NGROK_AUTHTOKEN/'"$ngrokAuthToken"'/g' ngrok/config.yml`

## Copy config to ~/.config/ngrok/config.yml 
`mkdir -p /home/$serviceUser/.config/ngrok/ && cp ngrok/config.yml /home/$serviceUser/.config/ngrok/config.yml`

################################ Installing GO

if [ ! -f /usr/local/go/bin/go ]; then
    echo -e "installing go"
    # `sudo wget https://golang.org/dl/go1.15.5.linux-amd64.tar.gz`
    `sudo tar -C /usr/local -xzf go1.15.5.linux-amd64.tar.gz`
    `echo "export PATH=$PATH:/usr/local/go/bin" >> /home/$serviceUser/.bashrc`
    `source /home/$serviceUser/.bashrc`
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
    source /home/$serviceUser/.bashrc

    echo -e "initializing ipfs"
    ipfs init
   
fi

sudo apt install jq -y
## ipfs api setup
`cat <<< $(jq '.API.HTTPHeaders = { "Access-Control-Allow-Methods": [ "PUT", "GET", "POST" ], "Access-Control-Allow-Origin": [ "*" ] }' /home/$serviceUser/.ipfs/config) > /home/$serviceUser/.ipfs/config`

## Setting up ipfs service
`cp ipfs/ipfs.service /etc/systemd/system/ipfs.service`
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
`cp ngrok/ngrok.service /etc/systemd/system/ngrok.service`
`sudo systemctl start ngrok`
`sudo systemctl enable ngrok`
