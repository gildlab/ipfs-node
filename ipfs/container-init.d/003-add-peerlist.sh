#!/bin/sh
set -euxo pipefail

cat peerlist
cat peerlist | xargs ipfs swarm peering add