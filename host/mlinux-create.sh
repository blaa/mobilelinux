#!/bin/bash

# The only script supposed to be run on a Linux desktop.
# Creates and minimally pre-configures Debian distribution.

WORKDIR=_work

# Configuration
IMAGE=$WORKDIR/linux.img

# Use < 4096MB for storing on vfat filesystem
MBYTES=4095

# Where to temporarily mount the image
MNTPNT=$WORKDIR/_mnt

# f2fs or ext4
FS=f2fs

# Basic set of packages added to the debootstrap process
# Prefer installing packages using apt-get later.
PACKAGES=openssh-server,vim-nox,strace,sudo,locales,net-tools,iproute2,dialog,apt-utils

# Install Debian base image - around 650MB taken after clean.
VARIANT=""
# minbase - image after creation and apt-get clean will take < 500MB.
VARIANT="--variant minbase"

SCRIPTS="../container/"

# DERIVED
PACKAGE_NAME="${IMAGE}_$(date +%Y%m%d_%H%M%S).img.gz"


# armel is for rather old phones. armhf should be ok.
ARCH=armhf
MIRROR=http://httpredir.debian.org/debian

function pre_cleanup () {
    echo "Pre-cleanup"
    mkdir -p $WORKDIR
    mkdir -p $MNTPNT
    umount $MNTPNT > /dev/null 2>&1
}

function create_image () {
    echo
    echo "* Create system image"
    marker=$WORKDIR/marker_filesystem_created
    if [ -f $marker ]; then
        echo "  ++ Skipping creation - marked as done - $marker"
        return
    fi

    # Security check
    if [ -f $IMAGE ]; then
        echo "  -- Image file seems to exist. Remove manually"
        exit 1
    fi

	dd if=/dev/zero of=$IMAGE bs=1M count=4090

    echo
	echo "* Create filesystem"
    case "$FS" in
    "ext4")
	    mkfs.ext4 -E nodiscard $IMAGE || exit
    ;;
    "f2fs")
        mkfs.f2fs -t 0 $IMAGE || exit
    ;;
    *)
        echo "Unknown Filesystem selected, add mkfs command to file or fix config"
        exit 1
    esac

    touch $marker
    echo "  ++ Marked as done"
}

function mount_image () {
    echo
    echo "* Mounting $IMAGE at $MNTPNT"
    grep $MNTPNT /proc/mounts > /dev/null
    if [ $? == 0 ]; then
        echo "  ++ Mount point already used (image mounted?)"
        return
    fi
    mount -o loop $IMAGE $MNTPNT || exit 1
}

function run_debootstrap () {
    echo
    echo "* Running debootstrap"
    marker_start=$WORKDIR/marker_deboostrap_started
    marker_done=$WORKDIR/marker_deboostrap_done
    if [ -f $marker_done ]; then
        echo "  ++ Skipping - marked as done - $marker_done"
        return
    fi

    if [ -f $marker_start ]; then
        echo "  -- Deboostrap started but not done. Remove marker - $marker_start"
        echo "     and cleanup mountpoint manually (or remove image and start over)"
        exit 1
    fi

    touch $marker_start
    echo "  ++ Marked as started"
    debootstrap --include=$PACKAGES --arch=$ARCH $VARIANT \
        --foreign jessie $MNTPNT $MIRROR || exit 1

    touch $marker_done
    echo "  ++ Marked as done"
}

function config () {
    # Everything that alters the image beyond default goes here.
    cp $SCRIPTS/init.sh $SCRIPTS/deinit.sh $MNTPNT/
    cp $SCRIPTS/postconfigure.sh $MNTPNT/root/

    if [ ! -f $MNTPNT/etc/hosts ] || ! grep -q '^127.0.0.1' $MNTPNT/etc/hosts; then
        echo '127.0.0.1    localhost ipv4-localhost localhost.localdomain' >> $MNTPNT/etc/hosts
        chmod a+r $MNTPNT/etc/hosts
    fi
}

function umount_image () {
    echo
    echo "* Umounting $IMAGE from $MNTPNT"
    grep -q $MNTPNT /proc/mounts
    if [ $? != 0 ]; then
        echo "  ++ mount point already unmounted"
        return
    fi
    umount $MNTPNT || exit 1
}


function package () {
    echo
    echo "* Packaging image into $PACKAGE_NAME"
    marker=$WORKDIR/marker_package_done
    if [ -f $marker ]; then
        echo "  ++ Skipping - marked as done - $marker"
        return
    fi

    gzip -1 -k -c $IMAGE > $PACKAGE_NAME
    if [ "$?" == 0 ]; then
        touch $marker
        echo "  ++ Done and marked as done"
    else
        echo "  -- Error while packaging"
    fi
}


pre_cleanup
create_image
mount_image
run_debootstrap
config
umount_image
package

# vim:ts=4:sw=4:expandtab:smarttab
