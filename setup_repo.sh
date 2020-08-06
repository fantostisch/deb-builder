#!/bin/sh
REPO_DIR=/var/www/repo/*

rm -rf ${REPO_DIR}
sudo mkdir -p ${REPO_DIR}/conf

sudo cp reprepro_distributions ${REPO_DIR}/conf/distributions

# fix permissions
sudo chown -R $(id -u -n).$(id -g -n) ${REPO_DIR}

# init repo
reprepro -b ${REPO_DIR} createsymlinks
reprepro -b ${REPO_DIR} export
