# Introduction

This document will explain how to set up a Debian package build server, from 
the builder itself to the web server hosting the packages (over TLS).

Install Debian 10 on a (virtual) machine. Make sure the following packages
are installed:

    $ sudo apt install pbuilder build-essential apache2 pkg-php-tools \
        dh-apache2 apt-utils git-buildpackage dh-golang dh-sysuser reprepro

# Web Server

In order to setup TLS:

    $ sudo apt install certbot python3-certbot-apache
    $ sudo certbot -d debian-vpn-builder.tuxed.net --apache
    $ sudo systemctl enable --now certbot.timer

# PGP

Generate an RSA 3072 key that expires in 5 years:

	$ gpg --batch --passphrase '' --quick-generate-key "Debian Packaging Key <debian@example.org>" default default 5y

**NOTE**: for production packages you SHOULD use a passphrase! 

After you generate it, verify it:

	$ gpg -K
	/home/fkooman/.gnupg/pubring.kbx
	--------------------------------
	sec   rsa3072 2020-08-12 [SC] [expires: 2025-08-11]
	      B5DA0D7AFFCD812FD066D2B1335F2E9D8FF4588D
	uid           [ultimate] Debian Packaging Key <debian@example.org>
	ssb   rsa3072 2020-08-12 [E]

# Builder

## Obtain

In order to setup your builder, download the scripts:

    $ git clone https://git.tuxed.net/deb/builder

## Setup

    $ cd builder

If you want to only build certain distros, you can create a file `dist_list` in 
the `builder` directory, e.g.:

    DIST_LIST="buster stretch"

By default the builder will build packages for `sid`, `bullseye`, `buster` and
`stretch`.

The setup the builder and repository:

    $ sudo ./builder_setup.sh
    $ ./setup_repo.sh

## Building Packages

Build all packages and add them to the repository:

    $ ./build_packages.sh

## Apache 

Put this in `/etc/apache2/conf-available/reprepro.conf`:

	Alias /repo /var/www/repo
	<Directory "/var/www/repo">
		Options Indexes FollowSymLinks Multiviews
		Require all granted
	</Directory>

	<Directory "/var/www/repo/db">
		Require all denied
	</Directory>

	<Directory "/var/www/repo/conf">
		Require all denied
	</Directory>

	<Directory "/var/www/repo/incoming">
		Require all denied
	</Directory>

Enable it:

	$ sudo a2enconf reprepro
	$ sudo systemctl restart apache2

# Repository User

Import the repository signing key:

    $ curl https://debian-vpn-builder.tuxed.net/repo/debian.key | sudo apt-key add

Add this to `/etc/apt/sources.list` on the server where you want to install the
software from the repository. This is usually _not_ your build server...

## Debian 9 (stretch)

    deb https://debian-vpn-builder.tuxed.net/repo stretch main

## Debian 10 (buster)

    deb https://debian-vpn-builder.tuxed.net/repo buster main

## Debian 11 (bullseye) 

We expect Debian 11 to be released somewhere in 2021, but there are already
packages available:

    deb https://debian-vpn-builder.tuxed.net/repo bullseye main

## Debian Unstable (sid)

    deb https://debian-vpn-builder.tuxed.net/repo sid main


# Updating Packages

## Setup 

Make sure the variables `DEBFULLNAME` and `DEBEMAIL` are set. This makes sure 
`dch` below uses this information to update the `debian/changelog` file. Add 
this to the bottom of `${HOME}/.profile`:

	export DEBFULLNAME="François Kooman"
	export DEBEMAIL=fkooman@tuxed.net

After this make sure you logout and in again.

## Package Update

In order to update a package, you can use the following commands:

	$ git clone git@git.tuxed.net:deb/php-saml-sp

We need to make the `upstream` branch available locally, not sure how to do
that properly, but this works:

	$ git checkout upstream
	$ git checkout main

Download the latest upstream tar release and verify the signature:

	$ uscan

Import the new release in the Git repository:

	$ gbp import-orig ../php-saml-sp-0.5.4.tar.xz

Update the `debian/changelog` file. Your editor will be opened.

	$ dch -v 0.5.4-1

The update message could be "update to 0.5.4". If you make any other changes to
the package, note them here as well. Finalize the changes:

	$ dch -r

Review the changes:

	$ git diff

If all looks good, commit and push the changes:

	$ git commit -a -m 'update to 0.5.4'
	
For `stretch` we have a separate branch for some packages, if that is the case
for the particular package you want to update, also merge the changes to the
`stretch` branch:

    $ git checkout stretch
    $ git merge main
    $ git checkout main
    
Now push all branches/tags to the server:

	$ git push origin --all
	$ git push origin --tags
