#!/bin/bash

DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ ! -f "$2" ]; then
	echo "$2 is not a file"
	exit 1
fi

# Workaround for potentially pulling in DOS mode
SCRIPT="$(sed 's/^M$//' "$2")"

ssh -F "$DIR/ssh_config" $1 'bash -s' <<EOF
$SCRIPT
EOF
