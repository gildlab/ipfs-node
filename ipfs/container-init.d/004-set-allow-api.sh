#!/bin/sh
set -euxo pipefail

# This is inside the docker container, nginx wraps it.
ipfs config --json Addresses.API "/ip4/0.0.0.0/tcp/5001"