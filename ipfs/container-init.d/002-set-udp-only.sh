#!/bin/sh
set -euxo pipefail

# https://github.com/ipfs/kubo/issues/3320#issuecomment-1321103079
ipfs config --bool Swarm.Transports.Network.TCP false
# https://github.com/ipfs/kubo/blob/master/docs/config.md#addressesswarm
ipfs config --json Addresses.Swarm '["/ip4/0.0.0.0/udp/4001/quic","/ip4/0.0.0.0/udp/4001/quic-v1","/ip4/0.0.0.0/udp/4001/quic-v1/webtransport","/ip6/::/udp/4001/quic","/ip6/::/udp/4001/quic-v1","/ip6/::/udp/4001/quic-v1/webtransport"]'