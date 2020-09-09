#!/bin/sh
set -e

DIST_LIST="sid bullseye buster stretch"
if [ -f "dist_list" ]; then
	. ./dist_list
fi

for DIST in ${DIST_LIST}
do
	(
		echo "*** ${DIST} ***"

		# the DIST environment variable is used by pbuilderrc
		export DIST
		/usr/sbin/pbuilder update
	)
done
