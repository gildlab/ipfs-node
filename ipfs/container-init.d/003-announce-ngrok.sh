#!/bin/sh
set -euxo pipefail

ipfs config --json Addresses.Announce '["/dns4/'"$NGROK_EDGE_HOSTNAME"'/tcp/'"$NGROK_EDGE_PORT"'"]'