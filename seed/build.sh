#!/bin/bash

DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
{
	cd "$DIR"
	./prepare.sh
	genisoimage -output seed.iso -volid cidata -joliet -rock user-data meta-data
}

