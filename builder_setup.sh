#!/bin/sh

DISTRO=sid

set -e

(
	cd /var/cache/pbuilder/result || exit 1
	/usr/bin/apt-ftparchive packages . > Packages
	/usr/bin/apt-ftparchive release . > Release
	/usr/bin/apt-ftparchive sources . > Sources 2>/dev/null
)

cp pbuilderrc /etc/pbuilderrc

# install hooks
mkdir -p /etc/pbuilder/hook.d
cp D70results /etc/pbuilder/hook.d
cp /usr/share/doc/pbuilder/examples/B90lintian /etc/pbuilder/hook.d
chmod +x /etc/pbuilder/hook.d/*

# create pbuilder root
/usr/sbin/pbuilder create --distribution ${DISTRO}
