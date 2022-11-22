@echo off

docker-compose "up" "-d"
sleep "60"
docker-compose "exec" "ipfs" "ipfs" "config" "--json" "API.HTTPHeaders.Access-Control-Allow-Origin" "[\"*\"]"
docker-compose "exec" "ipfs" "ipfs" "config" "--json" "API.HTTPHeaders.Access-Control-Allow-Methods" "[\"PUT\", \"GET\", \"POST\"]"