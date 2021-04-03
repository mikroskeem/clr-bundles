FROM clearlinux:base

RUN swupd bundle-add mixer

COPY ./docker/build_bundles.sh /build_bundles.sh

VOLUME /mixer
