#!/bin/bash

set -eo pipefail

BOARD=$1

if [[ "$(id -u)" -ne "0" ]]; then
    echo "This script requires root."
    exit 1
fi

mkdir -p /tmp/u-boot /usr/lib/u-boot-${BOARD}
dpkg -X /packages/${BOARD}-rk-ubootimg*.deb /tmp/u-boot
cp -rv /tmp/u-boot/usr/lib/u-boot-${BOARD}/*.img /usr/lib/u-boot-${BOARD}
