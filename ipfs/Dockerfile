FROM ipfs/kubo:v0.17.0

ADD ./container-init.d/001-set-allow-origin.sh /container-init.d/001-set-allow-origin.sh
RUN chmod a+x /container-init.d/001-set-allow-origin.sh /container-init.d/001-set-allow-origin.sh

ADD ./container-init.d/002-announce-ngrok.sh /container-init.d/002-announce-ngrok.sh
RUN chmod a+x /container-init.d/002-announce-ngrok.sh /container-init.d/002-announce-ngrok.sh

ADD ./container-init.d/003-add-peerlist.sh /container-init.d/003-add-peerlist.sh
RUN chmod a+x /container-init.d/003-add-peerlist.sh /container-init.d/003-add-peerlist.sh