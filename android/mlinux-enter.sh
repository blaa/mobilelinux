#!/bin/bash

# Description in mlinux-config.sh

# Script runs a single command within the container.

. ./mlinux-config.sh

sh mlinux-start.sh > /dev/null 2>&1
if [ "$?" != 0 ]; then
	echo "Unable to start container - unable to run a command"
	exit 1
fi

sh mlinux-run.sh "/bin/bash"
