#!/bin/sh

set -e

BUILD_DIR=/home/debian/build
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

for REPO in \
    https://salsa.debian.org/php-team/pear/php-constant-time \
    https://git.tuxed.net/deb/php-fkooman-secookie.deb \
    https://git.tuxed.net/deb/php-saml-sp.deb;
do
(
	if ! [ -d ${REPO} ]; then
		git clone ${REPO}
	        cd "$(basename ${REPO})"
	else
	        cd "$(basename ${REPO})"
		git pull
	fi
	uscan --download-current-version
	pdebuild
)
done
