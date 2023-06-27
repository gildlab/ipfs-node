#!/bin/sh
set -euxo pipefail

# moved to Routing.AcceleratedDHTClient in Kubo 0.21
ipfs config --bool Experimental.AcceleratedDHTClient null