FROM rclone/rclone:latest

ARG OVERLAY_VERSION="v1.22.1.0"
#ARG OVERLAY_ARCH="aarch64"
ARG OVERLAY_ARCH="amd64"

ENV DEBUG="false" \
    GOPATH="/go" \
    GO111MODULE="on" \
    AccessFolder="/mnt" \
    RemotePath="mediaefs:" \
    MountPoint="/mnt/mediaefs" \
    ConfigDir="/config" \
    ConfigName=".rclone.conf" \
    MountCommands="--allow-other --allow-non-empty" \
    UnmountCommands="-u -z"

## Alpine with Go Git
RUN apk --no-cache upgrade \
    && apk add --no-cache --update curl fuse fuse-dev gnupg \
    && echo "Installing S6 Overlay" \
    && curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" \
    && curl -o /tmp/s6-overlay.tar.gz.sig -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz.sig" \
    && gpg --keyserver pgp.surfnet.nl  --recv-keys 6101B2783B2FD161 \
    && gpg --verify /tmp/s6-overlay.tar.gz.sig /tmp/s6-overlay.tar.gz \
    && tar xfz /tmp/s6-overlay.tar.gz -C / \
    && apk del gnupg \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

COPY rootfs/ /

VOLUME ["/mnt"]

ENTRYPOINT ["/init"]
#CMD ["/start.sh"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared
