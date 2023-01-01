#!/bin/sh
set -ex

#https://github.com/ipfs-shipyard/go-ipfs-docker-examples/blob/main/gateway/ipfs-config.sh
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["*"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["POST"]'