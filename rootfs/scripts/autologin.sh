#!/bin/bash
# Install target board packages.

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
    echo "This script requires root."
    exit 1
fi

# Autologin
cat <<-EOF >> /usr/share/lightdm/lightdm.conf.d/01_debian.conf

[SeatDefaults]
autologin-user=rock
autologin-user-timeout=0
EOF

