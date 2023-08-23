#!/bin/bash

set -eou pipefail

SINCE=0
FILE_UPDATE_LAST=/tmp/update_last
if [ -f $FILE_UPDATE_LAST ]; then
    NOW=$(date "+%s")
    MODIFIED=$(date -r "$FILE_UPDATE_LAST" "+%s")
    SINCE=$(( $NOW - $MODIFIED ))
fi
if [ $SINCE -gt 600 ]; then
    sudo apt-get update
    touch $FILE_UPDATE_LAST
fi

# Install dependencies
sudo apt-get install -y \
    build-essential libx11-dev libxft-dev libxinerama-dev \
    xrdp xdg-utils xserver-xorg-dev xutils-dev xinit x11-xserver-utils
cd

mkdir -p projects
pushd projects
if ! command -v dwm &> /dev/null; then
    if [ ! -d dwm ]; then
        git clone https://git.suckless.org/dwm
    fi
    pushd dwm
    sudo make clean install
    popd
fi

if ! command -v dmenu &> /dev/null; then
    if [ ! -d dmenu ]; then
        git clone https://git.suckless.org/dmenu
    fi
    pushd dmenu
    sudo make clean install
    popd
fi

if ! command -v st &> /dev/null; then
    if [ ! -d st ]; then
        git clone https://git.suckless.org/st
    fi
    pushd st
    sudo make clean install
    popd
fi
popd

cat <<EOF > .xinitrc
exec dwm
EOF

# For XRDP use
cat <<EOF > .xsession
dwm
EOF
