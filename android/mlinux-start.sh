#!/bin/bash

# Full description in mlinux-config.sh

# Script for idempotently mounting Linux rootfs "container".
# Use like this: sh ./mlinux-start.sh

. ./mlinux-config.sh

function mount_if_required {
    # Mount device if it's not already mounted.
    fstype=$1
    opts=$2
    device=$3
    mntpnt=$4

    echo "* Mounting $mntpnt"
    grep $mntpnt /proc/mounts > /dev/null
    if [ "$?" == 0 ]; then
        echo "  ++ already mounted"
        return
    fi

    mkdir -p $mntpnt
    if [ "$?" != 0 ]; then
        echo "  -- mkdir failed - unable to mount."
        exit 1
    fi

    if [ $fstype == "bind" ]; then
        $BB mount --bind $device $mntpnt
    else
        $BB mount -t $fstype -o $opts $device $mntpnt
    fi
    if [ "$?" != 0 ]; then
        echo "  -- mount failed."
        exit 1
    else
        echo "  ++ Mounted"
    fi
}

function run_second_stage_debootstrap {
    # Execute second stage of debootstrap for fresh images
    # will be omitted when not needed. Includes a work-around for
    # debootstrap failing in one go (on python package in my case)

    echo
    echo "= Running second stage debootstrap"
    debootstrap=debootstrap/debootstrap

    if [ ! -f "$ROOTPATH/$debootstrap" ]; then
        echo "  ++ not needed"
        return
    fi

    echo "  ++ detected not finished configuration, running..."
    sh ./mlinux-run.sh "/debootstrap/debootstrap --second-stage"

    if [ -f "$ROOTPATH/$debootstrap" ]; then
        # FIXME: This should be enough, but isn't. Help it a bit.
        echo "  -- debootstrap not finishing; executing manual 'push'"
        sh ./mlinux-run.sh "/usr/bin/apt-get -y -f install"
        sh ./mlinux-run.sh "/debootstrap/debootstrap --second-stage"
    fi
    if [ ! -f "$ROOTPATH/$debootstrap" ]; then
        echo "  ++ debootstrap succesful, doing cleanup"
        sh ./mlinux-run.sh "/usr/bin/apt-get clean"
    else
        echo "  -- debootstrap failed, you need to fix it manually"
        echo "  -- removing '/debootstrap' dir will omit further debootstraps"
        exit 1
    fi
}

function run_init () {
    # Run system init script
    echo
    echo "= Running $SCRIPT_INIT script"
    if [ -f "$ROOTPATH/$SCRIPT_INIT" ]; then
        sh ./mlinux-run.sh "/bin/bash $SCRIPT_INIT"
    else
        echo "  -- Script not found"
    fi
}

echo
echo "= Mounting basic filesystems"
mount_if_required $FSTYPE noatime,nodiratime $IMAGE $ROOTPATH
mount_if_required proc rw proc $ROOTPATH/proc
mount_if_required sysfs rw,seclabel sysfs $ROOTPATH/sys
mount_if_required bind none /dev $ROOTPATH/dev
mount_if_required devpts defaults none $ROOTPATH/dev/pts

echo
echo "= Mounting additional filesystems"
for sdcard in /storage/sdcard*; do
    name=$(basename $sdcard)
    mount_if_required bind none $sdcard $ROOTPATH/mnt/$name
done
#mount_if_required bind none /data $ROOTPATH/android/data


run_second_stage_debootstrap
run_init


# vim:ts=4:sw=4:expandtab:smarttab
