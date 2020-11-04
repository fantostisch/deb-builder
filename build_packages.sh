#!/bin/sh
set -ex

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
	https://github.com/fantostisch/deb-vpn-lib-common \
	https://github.com/fantostisch/deb-vpn-server-api \
	https://github.com/fantostisch/deb-wireguard-vpn-user-portal \
	https://github.com/fantostisch/deb-vpn-server-node \
	https://git.tuxed.net/deb/vpn-maint-scripts \
	https://git.tuxed.net/deb/vpn-portal-artwork-eduvpn \
	https://git.tuxed.net/deb/vpn-portal-artwork-lc \
	https://git.tuxed.net/deb/php-saml-sp \
	https://git.tuxed.net/deb/php-saml-sp-artwork-eduvpn \
	https://github.com/fantostisch/golang-github-mdlayher-netlink \
	https://github.com/fantostisch/golang-github-jsimonetti-rtnetlink \
	https://github.com/fantostisch/golang-github-mdlayher-genetlink \
	https://github.com/fantostisch/golang-github-mikioh-ipaddr \
	https://github.com/fantostisch/golang-zx2c4-wireguard-wgctrl \
	https://github.com/fantostisch/deb-wireguard-daemon"

# helper function to check whether a file out of a list of files exists
fileExists() {
	for F in "$@"; do
		if [ -f "$F" ]; then
			return 0
		fi
	done
	return 1 
}

DIST_LIST="sid bullseye buster stretch"
if [ -f "dist_list" ]; then
        . ./dist_list
fi

for DIST in ${DIST_LIST}
do
	(
		echo "*** ${DIST} ***"
		BUILD_DIR=${HOME}/build/${DIST}
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
				if [ -d "${DIR_NAME}" ]; then
					# we already have the repo, clean and 
					# update it
					cd "${DIR_NAME}"
					sudo git clean -d -f
					git checkout -- .
					git checkout main || git checkout master || true
					git pull origin
				else 
					git clone "${REPO}"
					cd "${DIR_NAME}"
				fi

				if [ "stretch" = "${DIST}" ]; then
					git checkout stretch || true
					git pull origin || true
					dch -m -l "+deb9+eduvpn.org+" "Release for Debian 9 (stretch)"
					dch -m -r "Release for Debian 9 (stretch)"
				fi

				if [ "buster" = "${DIST}" ]; then
					dch -m -l "+deb10+eduvpn.org+" "Release for Debian 10 (buster)"
					dch -m -r "Release for Debian 10 (buster)"
				fi

				if [ "bullseye" = "${DIST}" ]; then
					dch -m -l "+deb11+eduvpn.org+" "Release for Debian 11 (bullseye)"
					dch -m -r "Release for Debian 11 (bullseye)"
				fi

				# check whether we already have a build with 
				# this exact version, if so, skip building it
				PACKAGE_MATCH=$(grep "Package:" debian/control | awk \{'print $2'\})_$(dpkg-parsechangelog -S version)
				if ! fileExists "/var/cache/pbuilder/${DIST}/result/${PACKAGE_MATCH}"*.deb;
				then
					echo "[BUILD] ${PACKAGE_MATCH}"
					# when using git commit ids, uscan always downloads the latest version
					# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=913970
					if [ "$DIR_NAME" = "golang-github-jsimonetti-rtnetlink" ]; then
						git pull --tags origin upstream
						gbp export-orig
					else
						# The filename of the source .tar.gz might be same, so use --rename.
						# For example the source file for for vpn-lib-common and vpn-server-api
						# is both wg-0.0.1.tar.gz. When building the vpn-server-api it will use
						# the source of vpn-lib-common, if we do not remove the source of
						# vpn-lib-common.
						uscan --download-current-version --rename
					fi
					# todo: run tests for netlink, currently not done because of circular
					# dependency on rtnetlink
					if [ "$DIR_NAME" = "golang-github-mdlayher-netlink" ]; then
					    DEB_BUILD_OPTIONS=nocheck
					else
					    DEB_BUILD_OPTIONS=""
					fi
					sudo DIST="${DIST}" HOME="${HOME}" DEB_BUILD_OPTIONS="$DEB_BUILD_OPTIONS" pdebuild --use-pdebuild-internal
				else
					echo "[SKIP] ${PACKAGE_MATCH}"
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
