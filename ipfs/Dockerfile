FROM ipfs/kubo:v0.21.0-rc3

ADD ./container-init.d/000-cleanup-deprecated-config.sh /container-init.d/000-cleanup-deprecated-config.sh
RUN chmod a+x /container-init.d/000-cleanup-deprecated-config.sh

ADD ./container-init.d/001-set-allow-origin.sh /container-init.d/001-set-allow-origin.sh
RUN chmod a+x /container-init.d/001-set-allow-origin.sh

ADD ./container-init.d/002-set-udp-only.sh /container-init.d/002-set-udp-only.sh
RUN chmod a+x /container-init.d/002-set-udp-only.sh
