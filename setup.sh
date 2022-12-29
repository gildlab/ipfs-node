#!/bin/bash

set -o errexit
set -o nounset

IFS=$(printf '\n\t')

# Docker
sudo apt remove --yes docker docker-engine docker.io containerd runc || true
sudo apt update
sudo apt --yes --no-install-recommends install apt-transport-https ca-certificates
wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository --yes "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release --codename --short) stable"
sudo apt update
sudo apt --yes --no-install-recommends install docker-ce docker-ce-cli containerd.io
sudo usermod --append --groups docker "$USER"
sudo systemctl enable docker
printf '\nDocker installed successfully\n\n'

printf 'Waiting for Docker to start...\n\n'
sleep 5

# Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
printf '\nDocker Compose installed successfully\n\n'
printf $(docker-compose --version)

if [[ -f ".env" ]]
then
    printf "\n\nexporting .env variables.\n\n"
    source .env
fi

# Get .env variables
if [[ ! -v NGROK_AUTH ]]
then
    read -p "Enter ngrok auth token : " ngrok_auth_token
    printf "NGROK_AUTH=${ngrok_auth_token}\n" >> .env
else
    printf "ngrok auth token found.\n\n"
fi

if [[ ! -v NGROK_HOSTNAME ]]
then
    read -p "Enter ngrok hostname : " ngrok_hostname
    if [[ ! -z "$ngrok_hostname" ]]
    then
    	printf "\nNGROK_HOSTNAME=${ngrok_hostname}" >> .env
    fi
else
    printf "ngrok hostname found.\n\n"
fi

if [[ ! -v NGROK_REGION ]]
then
    read -p "Enter ngrok region : " ngrok_region
    if [[ ! -z "$ngrok_region" ]]
    then
    	printf "\nNGROK_REGION=${ngrok_region}" >> .env
    fi
else
    printf "ngrok region found.\n\n"
fi

source .env

# Start Docker
docker-compose up -d
sleep 30
docker-compose exec ipfs ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'
docker-compose exec ipfs ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "GET", "POST"]'

# add ReceiptMetadata.json to ipfs
curl -F file=@ReceiptMetadata.json 'http://127.0.0.1:5001/api/v0/add?pin=true&to-files=/'

# opening firewall ports for communication
sudo ufw enable
sudo ufw allow 4001/tcp
sudo ufw allow 4001/udp
sudo ufw allow 5001/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 80/tcp
