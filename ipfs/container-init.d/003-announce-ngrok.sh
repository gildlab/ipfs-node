#!/bin/sh
set -euxo pipefail

ipfs config --json Addresses.AppendAnnounce '["/dns4/'"$NGROK_EDGE_HOSTNAME"'/tcp/'"$NGROK_EDGE_PORT"'"]'