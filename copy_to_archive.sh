#!/bin/sh

TARGET_FILE="${PWD}/repo-$(date +%Y%m%d%H%M%S).tar.xz"
(
	cd /var/www/repo || exit 1
	tar --exclude ./db --exclude ./conf -cJf "${TARGET_FILE}" .
)
