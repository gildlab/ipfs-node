ARG BRANCH=
FROM gildlab/ipfs-node:ipfs-$BRANCH

ADD ./container-init.d/002-announce-ngrok.sh /container-init.d/002-announce-ngrok.sh
RUN chmod a+x /container-init.d/002-announce-ngrok.sh /container-init.d/002-announce-ngrok.sh