#!/bin/sh

# Downloads the Debian tarball from the latest Synapse release on GitHub
# and extracts it into debian/incoming/.
set -euo pipefail

RELEASE_JSON=$( curl -s "https://api.github.com/repos/matrix-org/synapse/releases" | jq '.[0]' )

VERSION=$( echo $RELEASE_JSON | jq -r '.name' )
DOWNLOAD_URL=$( echo $RELEASE_JSON | jq -r '.assets | .[] | select(.name == "debs.tar.xz") | .browser_download_url' )

echo "Downloading $VERSION to debian/incoming..."

curl -L --progress-bar "$DOWNLOAD_URL" | tar -C debian/incoming --strip-components=1 -xJ

echo "Done."
