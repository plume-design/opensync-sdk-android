#!/bin/bash
export SDKMAN_DIR=/usr/local/sdkman
source /usr/local/sdkman/bin/sdkman-init.sh

exec "$@"
