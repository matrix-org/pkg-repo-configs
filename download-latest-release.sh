#!/bin/bash

set -euo pipefail

RELEASE_JSON=$( curl -s "https://api.github.com/repos/matrix-org/synapse/releases" | jq '.[0]' )

VERSION=$( echo $RELEASE_JSON | jq -r '.name' )
DOWNLOAD_URL=$( echo $RELEASE_JSON | jq -r '.assets | .[] | select(.name == "debs.tar.xz") | .browser_download_url' )

echo "Downloading $VERSION"

curl -L --progress-bar "$DOWNLOAD_URL" | tar -C debian/incoming --strip-components=1 -xJ

echo "Done."
