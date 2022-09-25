#!/bin/bash

set -eou pipefail

# Generate local SSH key just for demobox
[ ! -f ~/.ssh/id_demobox ] && mkdir -p ~/.ssh && ssh-keygen -b 4096 -t rsa -q -f ~/.ssh/id_demobox -N ""

# Read public key
KEY="$(<~/.ssh/id_demobox.pub)"

# Replace template placeholder with key
sed "s#\#\#SSH_KEY\#\##$KEY#g" user-data.template > user-data

# Copy unmodified template
cp meta-data.template meta-data
