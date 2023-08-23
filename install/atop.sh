#!/bin/bash

set -eou pipefail
sudo apt update
sudo apt install -y atop linux-headers-$(uname -r) make zlib1g-dev
cd
cd projects
if [ ! -d netatop-3.1 ];then
    wget https://www.atoptool.nl/download/netatop-3.1.tar.gz
    tar xvf netatop-3.1.tar.gz
    rm netatop-3.1.tar.gz
fi
cd netatop-3.1
make
sudo make install
sudo modprobe -v netatop
sudo systemctl enable netatop
