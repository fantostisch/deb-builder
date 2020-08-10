#!/bin/sh
set -e

#REPO_DIR=/var/www/repo

#for DIST in sid bullseye buster
#for DIST in sid bullseye
for DIST in sid
do
	(
		BUILD_DIR=${HOME}/build/${DIST}
		rm -rf "${BUILD_DIR}"
		mkdir -p "${BUILD_DIR}"
		cd "${BUILD_DIR}" || exit 1

#		    https://git.tuxed.net/deb/php-secookie \
#		    https://git.tuxed.net/deb/php-jwt \
#		    https://git.tuxed.net/deb/php-oauth2-server \
#		    https://git.tuxed.net/deb/php-openvpn-connection-manager \
#		    https://git.tuxed.net/deb/php-otp-verifier \
#		    https://git.tuxed.net/deb/php-sqlite-migrate \
#		    https://git.tuxed.net/deb/php-saml-sp \
#		    https://git.tuxed.net/deb/vpn-ca \
#		    https://git.tuxed.net/deb/vpn-daemon \
#		    https://git.tuxed.net/deb/vpn-lib-common \
#		    https://git.tuxed.net/deb/vpn-server-api \
#		    https://git.tuxed.net/deb/vpn-user-portal \
#		    https://git.tuxed.net/deb/vpn-server-node \
		#    https://git.tuxed.net/deb/vpn-maint-scripts \
		#    https://git.tuxed.net/deb/vpn-portal-artwork-eduvpn \
		#    https://git.tuxed.net/deb/vpn-portal-artwork-lc \
		#    https://git.tuxed.net/deb/php-saml-sp-artwork-eduvpn;

		# not needed on sid
		#    https://git.tuxed.net/deb/php-constant-time \

		for REPO in https://git.tuxed.net/deb/php-secookie;
		do
		(
			DIR_NAME=$(basename "${REPO}")
			git clone "${REPO}"
			cd "${DIR_NAME}"
			uscan --download-current-version
			sudo pdebuild
		)
		done
	)
done

## add all deb/src packages to repository
#cd ${RESULT_DIR}
#for P in *.changes; do
#	reprepro -b ${REPO_DIR} include ${DISTRO} ${P}
#done
