FROM ipfs/kubo

ADD ./container-init.d/001-set-profile.sh /container-init.d/001-set-profile.sh
RUN chmod a+x /container-init.d/001-set-profile.sh

ADD ./container-init.d/002-set-allow-origin.sh /container-init.d/002-set-allow-origin.sh
RUN chmod a+x /container-init.d/002-set-allow-origin.sh /container-init.d/002-set-allow-origin.sh

ADD ./container-init.d/003-announce-ngrok.sh /container-init.d/003-announce-ngrok.sh
RUN chmod a+x /container-init.d/003-announce-ngrok.sh /container-init.d/003-announce-ngrok.sh