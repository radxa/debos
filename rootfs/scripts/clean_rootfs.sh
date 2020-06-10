#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
    echo "This script requires root."
    exit 1
fi

# Clean rootfs
rm -rf /etc/apt/sources.list.d/*.key
rm -rf /packages
rm -rf /var/lib/apt/lists/*
