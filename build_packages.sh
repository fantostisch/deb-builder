#!/bin/sh
set -e

REPO_DIR=/var/www/repo

PACKAGE_LIST="
	https://git.tuxed.net/deb/php-secookie \
	https://git.tuxed.net/deb/php-jwt \
	https://git.tuxed.net/deb/php-oauth2-server \
	https://git.tuxed.net/deb/php-openvpn-connection-manager \
	https://git.tuxed.net/deb/php-otp-verifier \
	https://git.tuxed.net/deb/php-sqlite-migrate \
	https://git.tuxed.net/deb/vpn-ca \
	https://git.tuxed.net/deb/vpn-daemon \
	https://git.tuxed.net/deb/vpn-lib-common \
	https://git.tuxed.net/deb/vpn-server-api \
	https://git.tuxed.net/deb/vpn-user-portal \
	https://git.tuxed.net/deb/vpn-server-node \
	https://git.tuxed.net/deb/php-saml-sp"

#https://git.tuxed.net/deb/vpn-maint-scripts \
#https://git.tuxed.net/deb/vpn-portal-artwork-eduvpn \
#https://git.tuxed.net/deb/vpn-portal-artwork-lc \
#https://git.tuxed.net/deb/php-saml-sp-artwork-eduvpn;

for DIST in sid bullseye buster
do
	(
		echo "*** ${DIST} ***"
		BUILD_DIR=${HOME}/build/${DIST}
		sudo rm -rf "${BUILD_DIR}"
		mkdir -p "${BUILD_DIR}"
		cd "${BUILD_DIR}" || exit 1

		if [ "sid" != "${DIST}" ]; then
			# php-constant-time is only available in sid
			PACKAGE_LIST="https://salsa.debian.org/php-team/pear/php-constant-time ${PACKAGE_LIST}"
		fi

		for REPO in ${PACKAGE_LIST}; do
			(
				echo "*** ${REPO} ***"
				DIR_NAME=$(basename "${REPO}")
				git clone "${REPO}"
				cd "${DIR_NAME}"

				if [ "buster" = ${DIST} ]; then
					dch -m -l "eduvpn+deb10u1" "Release for Debian 10 (buster)"
					dch -m -r "Release for Debian 10 (buster)"
				fi

				if [ "bullseye" = ${DIST} ]; then
					dch -m -l "eduvpn+deb11u1" "Release for Debian 11 (bullseye)"
					dch -m -r "Release for Debian 11 (bullseye)"
				fi

                # check whether we already have a build with this exact 
                # version, if so, skip building it
                PACKAGE_MATCH=$(grep "Package:" debian/control | awk \{'print $2'\})_$(dpkg-parsechangelog -S version)
                if ! fileExists /var/cache/pbuilder/${DIST}/result/${PACKAGE_MATCH}*.deb;
                    echo "BUILDING!"
				    #uscan --download-current-version
				    #sudo DIST="${DIST}" HOME="${HOME}" pdebuild --use-pdebuild-internal
                fi
			)
		done

		# add (new) packages to repository
		BUILDRESULT="/var/cache/pbuilder/${DIST}/result"
		for PACKAGE in "${BUILDRESULT}/"*.deb; do
			reprepro -b ${REPO_DIR} includedeb "${DIST}" "${PACKAGE}" || true
		done
	)
done

fileExists() {
	for F in "$@"; do
		if [ -f "$F" ]; then
			return 0
		fi
	done
	return 1 
}
