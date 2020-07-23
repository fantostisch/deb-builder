#!/bin/sh

set -e

BUILD_DIR=/home/debian/build
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

for REPO in \
    https://salsa.debian.org/php-team/pear/php-constant-time.git \
    https://git.tuxed.net/deb/php-fkooman-secookie.deb \
    https://git.tuxed.net/deb/php-saml-sp.deb;
do
	git clone ${REPO}
	cd "$(basename ${REPO})"
	uscan --download-current-version
	pdebuild
done
