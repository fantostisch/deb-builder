#!/bin/sh

REPO_DIR=/var/www/html/repo/buster

mkdir -p ${REPO_DIR}
cp /var/cache/pbuilder/result/* ${REPO_DIR}
cd ${REPO_DIR}
/usr/bin/apt-ftparchive packages . > Packages
/usr/bin/apt-ftparchive release . > Release
/usr/bin/apt-ftparchive sources . > Sources 2>/dev/null

gpg --yes --clear-sign -a -o InRelease Release
gpg --yes --detach-sign -a -o Release.gpg Release
