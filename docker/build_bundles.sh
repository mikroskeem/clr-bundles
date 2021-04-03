#!/usr/bin/env bash
set -euo pipefail

# This should run in the container

exec 3>&1
exec 1>&2

REPO=/mixer
REPO_NAME=local-repo
REPO_PUB_PATH=/mixer/update/www
REPO_URL="file://${REPO_PUB_PATH}"

set -x
pushd "${REPO}" >/dev/null

if [ ! -d "${REPO}"/private.pem ]; then
	echo ">>> Initializing new repository"
	mixer init --no-default-bundles
	mixer config set Swupd.BUNDLE "os-core"
	mixer config set Swupd.CONTENTURL "${REPO_URL}"
	mixer config set Swupd.VERSIONURL "${REPO_URL}"

	# Required bundle
	mixer bundle create os-core --local
	mixer bundle add os-core

	mixer build bundles
	mixer build update
fi

# Update repository state
for f in "${REPO}"/local-bundles/*; do
	name="$(basename -- "${f}")"

	mixer bundle add "${name}"
done

swupd 3rd-party add "${REPO_NAME}" "${REPO_URL}" --allow-insecure-http --assume=yes --no-progress --quiet
for bundle in $(swupd 3rd-party bundle-list --no-progress --quiet --all --repo "${REPO_NAME}"); do
	if ! [ -f "${REPO}"/local-bundles/"${bundle}" ]; then
		mixer bundle remove "${bundle}"
	fi
done

# Build bundles and update the repository
mixer build bundles
mixer build update

# Export the archive
. /etc/os-release
echo ">>> Clear Linux version: '${BUILD_ID}'"

tar -C "${REPO_PUB_PATH}" -cvf - . 1>&3
