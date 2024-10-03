FROM alpine

ARG BUILD_DATE
ARG BUILD_VERSION

# OCI Meta information
LABEL \
    org.opencontainers.image.authors="Axel LORENTE (https://github.com/Passific)" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.version=${BUILD_VERSION} \
    org.opencontainers.image.title="MQTT iPhone Tracker"

VOLUME /opt/certs

ADD run.sh /tmp/run.sh

RUN apk add --no-cache ca-certificates tini mosquitto-clients && \
    /etc/ca-certificates/update.d/certhash && \
    ln -s /usr/bin/mosquitto_pub /usr/local/bin/pub && \
    ln -s /usr/bin/mosquitto_sub /usr/local/bin/sub && \
    chmod +x /tmp/run.sh

RUN apk add -X http://dl-cdn.alpinelinux.org/alpine/edge/testing hping3

#USER nobody
ENTRYPOINT [ "/sbin/tini", "--", "/tmp/run.sh" ]
CMD []
