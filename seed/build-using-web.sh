#!/bin/bash

DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
{
	cd "$DIR"
	./prepare.sh
	USER_DATA="$(cat "user-data" | base64)"
	META_DATA="$(cat "meta-data" | base64)"

	curl -X POST \
		-o seed.iso \
		-F "user_data=$USER_DATA" \
		-F "meta_data=$META_DATA" \
		https://tools.stwcreation.com/genisoimage/
}
