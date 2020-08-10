#!/bin/sh
set -e

cp pbuilderrc /etc/pbuilderrc

#for DIST in sid bullseye buster
#for DIST in sid bullseye
for DIST in sid
do
	(
		echo "*** ${DIST} ***"

		# install hooks
		rm -rf "/etc/pbuilder/hook.d/*"
		mkdir -p "/etc/pbuilder/hook.d/${DIST}"
		cp hooks/* "/etc/pbuilder/hook.d/${DIST}"
		# install distro specific hooks (if available)
		if [ -d "hooks/${DIST}" ]; then
			cp hooks/${DIST}/* "/etc/pbuilder/hook.d/${DIST}"
		fi

		# create an empty package repository that will be updated before every
		# package build...
		rm -rf "/var/cache/pbuilder/${DIST}/result"
		mkdir -p "/var/cache/pbuilder/${DIST}/result"
		(
			cd "/var/cache/pbuilder/${DIST}/result" || exit 1
			/usr/bin/apt-ftparchive packages . > Packages
			/usr/bin/apt-ftparchive release  . > Release
			/usr/bin/apt-ftparchive sources  . > Sources 2>/dev/null
		)

		# create the root for this distribution 
		mkdir -p "/var/cache/pbuilder/${DIST}/aptcache"

		# the DIST environment variable is used by pbuilderrc
		export DIST
		/usr/sbin/pbuilder create
	)
done
