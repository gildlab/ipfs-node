#!/bin/sh
set -euxo pipefail

ipfs config --json Addresses.AppendAnnounce '["/dns/'"$GILDLAB_IPFS_NODE_TCP_HOSTNAME"'/tcp/'"$GILDLAB_IPFS_NODE_TCP_PORT"'"]'