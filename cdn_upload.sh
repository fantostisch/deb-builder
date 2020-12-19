#!/bin/sh

# CDN
SERVER_LIST="eduvpn-repo@tromso-cdn.eduroam.no eduvpn-repo@ifi2-cdn.eduroam.no"
for SERVER in ${SERVER_LIST}; do
	echo "${SERVER}..."
        # Debian
	rsync -e ssh -rltO --delete /var/www/repo/*.key /var/www/repo/dists /var/www/repo/pool "${SERVER}:/srv/repo.eduvpn.org/www/v2/deb" || echo "FAIL ${SERVER}"
done
