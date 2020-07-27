# Introduction

Install Debian 10 on a (virtual) machine. Make sure the following packages
are installed:

    $ sudo apt install pbuilder build-essential apache2 pkg-php-tools \
        dh-apache2 apt-utils git-buildpackage

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
    uid           [ultimate] Let's Connect (Debian 10) <software+debian@letsconnect-vpn.org>
    ssb   rsa3072 2020-07-23 [E] [expires: 2022-07-23]

Put a copy of the public key in the web folder:

    $ sudo mkdir -p /var/www/html/repo
    $ sudo chown $(id -u -n).$(id -g -n) /var/www/html/repo
    $ gpg --export -a > /var/www/html/repo/buster.key

# Builder

## Obtain

In order to setup your builder, download the scripts:

    $ git clone https://git.tuxed.net/deb/builder

## Setup

    $ cd builder
    $ sudo ./builder_setup.sh

## Building Packages

    $ cd builder
    $ sudo ./build_packages.sh

## Repository

In order to copy the repository to the web server, do the following, _NOT_ with
`sudo`:

    $ cd builder
    $ ./repo_copy_sign.sh

That's all. You should have a working repository now.

# Repository User

Add this to `/etc/apt/sources.list` on the server where you want to install the
software from the repository. This is usually _not_ your build server...

    deb https://debian-vpn-builder.tuxed.net/repo/buster ./

Import the repository signing key:

    $ curl https://debian-vpn-builder.tuxed.net/repo/buster.key | sudo apt-key add

Now you should be able to install packages:

    $ sudo apt update
    $ sudo apt install php-saml-sp
