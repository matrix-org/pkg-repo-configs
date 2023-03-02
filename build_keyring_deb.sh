#!/bin/bash

# Builds a keyring deb and imports it into the local reprepro DB. 
#
# NOTE: If you update the key you will need to bump the version in
# `matrix-org-archive-keyring/DEBIAN/control`.

set -euo pipefail

mkdir -p matrix-org-archive-keyring/usr/share/keyrings/

echo "Downloading keyring.gpg..."
wget "https://packages.matrix.org/debian/matrix-org-archive-keyring.gpg" -O matrix-org-archive-keyring/usr/share/keyrings/matrix-org-archive-keyring.gpg

echo "Downloaded key:"
gpg --import --import-options show-only matrix-org-archive-keyring/usr/share/keyrings/matrix-org-archive-keyring.gpg

read -p "Press any key to continue..."

echo "Building deb..."
# Ensure that we add the keyring with the right permissions.
chmod u=rw,go=r matrix-org-archive-keyring/usr/share/keyrings/matrix-org-archive-keyring.gpg
dpkg-deb -Zxz --root-owner-group --build matrix-org-archive-keyring matrix-org-archive-keyring.deb

for dist in $(ls -1 "packages.matrix.org/debian/dists")
do
	echo "Importing deb into $dist..."
	reprepro -b debian/ -C "main"  includedeb  $dist matrix-org-archive-keyring.deb
	reprepro -b debian/ -C "prerelease"  includedeb  $dist matrix-org-archive-keyring.deb
done

echo "Done!"
