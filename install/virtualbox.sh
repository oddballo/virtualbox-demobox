#!/bin/bash

set -eou pipefail

sudo apt-get update
sudo apt-get install dkms linux-headers-$(uname -r) \
    build-essential libxt6 libxmu6

FILE_SCRIPT=/mnt/VBoxLinuxAdditions.run
if [ ! -f $FILE_SCRIPT ]; then
sudo mount /dev/cdrom /mnt
fi

sudo $FILE_SCRIPT
sudo reboot

