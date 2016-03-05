#!/bin/bash

# Description in mlinux-config.sh

# Script runs a single command within the container.

. ./mlinux-config.sh

chroot=$(which chroot)

export PATH=/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

if [ -f "$ROOTPATH/usr/bin/sudo" ]; then
    exec $chroot $ROOTPATH sudo -i -u root $*
else
    exec $chroot $ROOTPATH bash -l -c -- "$*"
fi
