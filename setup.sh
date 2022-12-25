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
    echo "\n\nexporting .env variables."
    source .env
fi

# Get .env variables
if [[ ! -v NGROK_AUTH ]]
then
    echo "Enter ngrok auth token : "
    read ngrok_auth_token
    export NGROK_AUTH="$ngrok_auth_token"
else
    echo "ngrok auth token found."
fi

if [[ ! -v NGROK_HOSTNAME ]]
then
    echo "Enter ngrok hostname : "
    read ngrok_hostname
    export NGROK_HOSTNAME="$ngrok_hostname"
else
    echo "ngrok hostname found."
fi

if [[ ! -v NGROK_REGION ]]
then
    echo "Enter ngrok region : "
    read ngrok_region
    export NGROK_REGION="$ngrok_region"
else
    echo "ngrok region found."
fi

# Start Docker
docker-compose up -d
sleep 60
docker-compose exec ipfs ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'
docker-compose exec ipfs ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "GET", "POST"]'

# add ReceiptMetadata.json to ipfs
curl -F file=@ReceiptMetadata.json 'http://127.0.0.1:5001/api/v0/add?pin=true&to-files=/'
