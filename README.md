# Introduction

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

    $ gpg --generate-key

It is easy to not set a password, so you don't need to provide it every time. 
Of course this is only acceptable for development...

After you generate it, verify it:

    $ gpg -K
    /home/debian/.gnupg/pubring.kbx
    -------------------------------
    sec   rsa3072 2020-07-23 [SC] [expires: 2022-07-23]
          0A9D8A595B9B0408D8C7680E9ADF44C54EB48E5F
    uid           [ultimate] Debian Packaging Key <debian@example.org>
    ssb   rsa3072 2020-07-23 [E] [expires: 2022-07-23]

# Builder

## Obtain

In order to setup your builder, download the scripts:

    $ git clone https://git.tuxed.net/deb/builder

## Setup

    $ cd builder
    $ sudo ./builder_setup.sh
    $ ./setup_repo.sh

## Building Packages

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

## Debian 10 (buster)

    deb https://debian-vpn-builder.tuxed.net/repo buster main

## Debian 11 (bullseye) 

We expect Debian 11 to be released somewhere in 2021, but there are already 
pacakges available:

    deb https://debian-vpn-builder.tuxed.net/repo bullseye main

## Debian Unstable (sid)

    deb https://debian-vpn-builder.tuxed.net/repo sid main
