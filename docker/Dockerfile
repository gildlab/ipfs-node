# Full build with debuginfo for graph-node
#
# The expectation if that the docker build uses the parent directory as PWD
# by running something like the following
#   docker build --target STAGE -f docker/Dockerfile .

# The full URL to the IPFS node
ENV ipfs ""

COPY docker/Dockerfile /Dockerfile
COPY docker/bin/* /usr/local/bin/
