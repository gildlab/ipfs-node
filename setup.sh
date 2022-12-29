#!/bin/bash

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
printf "\n\nStarting Docker."
docker-compose up -d

# opening firewall ports for communication
sudo ufw enable
sudo ufw allow 4001/tcp
sudo ufw allow 4001/udp
sudo ufw allow 5001/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 80/tcp
