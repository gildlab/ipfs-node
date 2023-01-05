#!/bin/sh
set -euxo pipefail

touch peerlist
cat peerlist | xargs ipfs swarm peering add