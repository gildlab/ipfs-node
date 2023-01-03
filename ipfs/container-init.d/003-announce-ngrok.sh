#!/bin/sh
set -euxo pipefail

ipfs config --json Addresses.Announce '["/dns4/'"$NGROK_HOSTNAME"'/tcp/'"$NGROK_PORT"'"]'