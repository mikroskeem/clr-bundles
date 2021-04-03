#!/usr/bin/env bash
set -euo pipefail

export DOCKER_BUILDKIT=1

docker build \
	"${@}" \
        -t clr-mixer \
        -f docker/Dockerfile .
