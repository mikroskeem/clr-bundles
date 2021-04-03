#!/usr/bin/env bash

img=clr-mixer:latest

docker run --rm --name clr-mixer \
	-v "$(realpath -- ./data)":/mixer \
	-v "$(realpath -- ./docker/build_bundles.sh)":/build_bundles.sh \
	-v "$(realpath -- ./bundles)":/mixer/local-bundles:ro \
	"${img}" /build_bundles.sh
