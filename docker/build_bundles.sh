#!/usr/bin/env bash
set -euo pipefail

# This should run in the container

exec 3>&1
exec 1>&2

REPO=/mixer
REPO_NAME=local-repo
REPO_PUB_PATH=/mixer/update/www
REPO_URL="file://${REPO_PUB_PATH}"

# Debugging aid
if [ "${CLR_VERBOSE:=false}" = "true" ]; then
	set -x
fi

devnull=/dev/null

pushd "${REPO}" >/dev/null

if [ ! -f "${REPO}"/private.pem ]; then
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

# Add the repository and check for removed bundles
# `swupd 3rd-party add` output is spammy even with `--quiet` (outputs whole certificate), silence it.
swupd 3rd-party add "${REPO_NAME}" "${REPO_URL}" --allow-insecure-http --assume=yes --no-progress --quiet >"${devnull}"

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
cat > "${REPO_PUB_PATH}"/.clr.json <<EOF
{"version":"${BUILD_ID}","timestamp":"$(date +%s)"}
EOF

tar -C "${REPO_PUB_PATH}" -cf - . 1>&3
