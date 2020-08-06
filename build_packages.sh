#!/bin/sh

DISTRO=sid
REPO_DIR=/var/www/repo
RESULT_DIR=/var/cache/pbuilder/result

set -e

BUILD_DIR=${HOME}/build
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

#    https://git.tuxed.net/deb/vpn-maint-scripts \
#    https://git.tuxed.net/deb/vpn-portal-artwork-eduvpn \
#    https://git.tuxed.net/deb/vpn-portal-artwork-lc \
#    https://git.tuxed.net/deb/php-saml-sp-artwork-eduvpn;

# not needed on sid
#    https://git.tuxed.net/deb/php-constant-time \

for REPO in \
    https://git.tuxed.net/deb/php-secookie \
    https://git.tuxed.net/deb/php-jwt \
    https://git.tuxed.net/deb/php-oauth2-server \
    https://git.tuxed.net/deb/php-openvpn-connection-manager \
    https://git.tuxed.net/deb/php-otp-verifier \
    https://git.tuxed.net/deb/php-sqlite-migrate \
    https://git.tuxed.net/deb/php-saml-sp \
    https://git.tuxed.net/deb/vpn-ca \
    https://git.tuxed.net/deb/vpn-daemon \
    https://git.tuxed.net/deb/vpn-lib-common \
    https://git.tuxed.net/deb/vpn-server-api \
    https://git.tuxed.net/deb/vpn-user-portal \
    https://git.tuxed.net/deb/vpn-server-node;
do
(
	DIR_NAME=$(basename ${REPO})
	# maybe we already checked out the code before...
	if ! [ -d "${DIR_NAME}" ]; then
		git clone ${REPO}
	else
		(
			cd "${DIR_NAME}"
			# try to update repo
			git fetch origin
			# make sure we are on HEAD...
			git checkout HEAD
			git pull origin HEAD
		)
	fi
	cd "${DIR_NAME}"

	# ... as this may fail if there is no such branch
	git checkout ${DISTRO} || true
	git pull origin ${DISTRO} || true

	uscan --download-current-version
	sudo pdebuild
)
done

# add all deb/src packages to repository
cd ${RESULT_DIR}
for P in *.changes; do
	reprepro -b ${REPO_DIR} include ${DISTRO} ${P}
done
