Mobile Linux
====================

Scripts for advanced Linux users for setting up a vanilla Debian
container on an Android device.
* Allow easy modification of startup/shutdown scripts without altering
  internals of any Android apps.
* Do as little modifications as possible and keep the whole process
  transparent.

Project consists of:
* host/linux_create.sh - creates a Debian image file on the Linux
  desktop machine.
* android/* - scripts automating starting/stopping the container
  (mounts, startup script) and running a command inside the container.
* container/* - optional post-install configuration script,
  init/deinit scripts.

Generic approach is to start SSH inside the container using init.sh
and then use any Android SSH client to log into the container. One can
use VNC/XPRA clients as well to use a graphical desktop.

All scripts should be idempotent.  You can use any Linux ARM image,
also those created using Linux Deploy. I made this scripts because I
couldn't easily alter the Linux Deploy app.

License: GNU GPLv3
Author: 2016, Tomasz bla Fortuna

Worthy alternatives
--------------------

This one might particularly be better for you, I didn't know about it
when I started:
* https://github.com/guardianproject/lildebi/wiki

Other + howtos:
* Linux Deploy app by Meefik.
* http://whiteboard.ping.se/Android/Debian
* https://wiki.debian.org/ChrootOnAndroid

Requirements
--------------------

Android device requirements:
* Rooted Android
* > 2GB free space on sdcard or internal storage.
* Installed BusyBox (Tested with the Meefik package)
* Free RAM according to your needs
* SSH Client to connect to the image with nice terminal.
* Way to run scripts on the device (terminal) and automate their
  execution (like Juice SSH snippets). Every restart you'll have to
  start the container somehow.


Usage
====================

1. Create Debian image using host/mlinux-create.sh script or Linux
   Deploy Android app.
2. Copy android/* scripts and image to your android device. Unpack the image.
3. Ensure you have a working busybox install, enough disc space and RAM.
4. Edit mlinux-config.sh so that the path to the image is correct.
5. In a terminal on Android:
  - su
  - cd /sdcard/mlinux/android # Whereever your stored the scripts
  - sh mlinux-start.sh
    This should run a second part of the debootstrap for the first
    time and can take a while.
  - sh mlinux-enter.sh
    Set up your main user or set root password (and allow root SSH login).
  - SSH to localhost on your new user.
  - Automate container start & enjoy.


Troubleshooting
====================
Second stage of debootstrap on the device needs to be left alone while
it works and device requires a reboot afterwards. I should probably
NOT bind /dev - rather copy required files.
