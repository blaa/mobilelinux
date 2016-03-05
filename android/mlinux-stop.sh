#!/bin/sh

# Full description in mlinux-config.sh

# Scripts for mounting linux image and starting SSH inside.
# more/less what linux deploy does but simple and easier to alter.
# Author: Tomasz bla Fortuna

. ./mlinux-config.sh

function umount_smart {
    # Mount device if it's not already mounted
    mntpnt=$1
    echo "* Unmounting $mntpnt"

    $GREP $mntpnt /proc/mounts > /dev/null
    if [ "$?" != 0 ]; then
        echo "  + already unmounted"
        return 0
    fi

    $UMOUNT $mntpnt
    if [ "$?" != 0 ]; then
        echo "  - umount failed, will continue"
	return 1
    else
        echo "  + unmounted"
    fi
}

echo "= Running $SCRIPT_FINI script"
if [ -f "$ROOTPATH/$SCRIPT_FINI" ]; then
    sh ./mlinux-run.sh /bin/bash $SCRIPT_FINI
else
    echo "  -- Script not found, ignoring"
fi

echo
echo "= Unmounting additional filesystems"

# Umount sdcards
for mntpnt in $ROOTPATH/mnt/*; do
    umount_smart $mntpnt
done

echo
echo "= Unmounting basic filesystems"
umount_smart $ROOTPATH/dev/pts
umount_smart $ROOTPATH/dev

umount_smart $ROOTPATH/sys
umount_smart $ROOTPATH/proc
umount_smart $ROOTPATH

echo
echo "= Check / help"
$GREP $ROOTPATH /proc/mounts > /dev/null
if [ "$?" == 0 ]; then
    echo "  -- System still not unmounted"
    echo "  Note: Unmount is very likely to fail if any processes are "
    echo "        still running in chroot. Kill them manually if needed"
    echo "  Here is a list of processes that might still be using the image"
    $LSOF | $GREP -i $ROOTPATH
else
    echo "  ++ System unmounted correctly"
fi
