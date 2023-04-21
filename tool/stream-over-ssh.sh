#!/bin/bash

DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ -f "$2" ]; then
	# Workaround for potentially pulling in DOS mode
	SCRIPT="$(sed 's/^M$//' "$2")"
else
	# Accept input as raw data
	SCRIPT="$2"
fi

ssh -F "$DIR/ssh_config" 127.0.0.1 -p $1 'bash -s' <<EOF
$SCRIPT
EOF
