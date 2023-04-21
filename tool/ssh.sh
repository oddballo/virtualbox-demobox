#!/bin/bash

DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ssh -F "$DIR/ssh_config" 127.0.0.1 -p $@
