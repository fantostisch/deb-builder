#!/bin/sh

set -e

BUILD_DIR=/home/debian/build
rm -rf ${BUILD_DIR}
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

for REPO in \
    https://salsa.debian.org/php-team/pear/php-constant-time \
    https://git.tuxed.net/deb/php-secookie \
    https://git.tuxed.net/deb/php-saml-sp \
    https://git.tuxed.net/deb/php-jwt \
    https://git.tuxed.net/deb/php-oauth2-server \
    https://git.tuxed.net/deb/php-openvpn-connection-manager \
    https://git.tuxed.net/deb/php-otp-verifier;
do
(
	DIR_NAME=$(basename ${REPO})
	if ! [ -d "${DIR_NAME}" ]; then
		git clone ${REPO}
	fi
	cd "$(DIR_NAME)"
	git pull
	uscan --download-current-version
	pdebuild
)
done
