#!/bin/bash

# Scripts for mounting linux image and starting SSH inside.
# more/less what Linux Deploy does but simple and easier to alter.
# Scripts require Busybox to function; Tested using Meefik Busybox.

# Author: Tomasz bla Fortuna
# License: GNU GPLv3

IMAGE="/storage/sdcard1/linux.img"
ROOTPATH="/data/local/mobilelinux"
FSTYPE=f2fs

# Scripts executed within chroot
SCRIPT_INIT='/init.sh'
SCRIPT_FINI='/deinit.sh'

# Busybox executable
BB="busybox"



# Derived
MOUNT="$BB mount"
UMOUNT="$BB umount"
GREP="$BB grep"
LSOF="$BB lsof"
