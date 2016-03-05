#!/bin/bash

# My helper for post-creation configuration; to be run inside the container.
# You should probably alter it for your needs and then keep handy.

# Config tracking.
apt-get install -y --no-install-recommends git
git config --global user.name "Administrator"
git config --global user.email 'admin@localhost'

apt-get install --no-install-recommends -y etckeeper


# Command used to start everything automatically:
# /etc/init.d/rc 2
# Stop everything:
# /etc/init.d/rc 0
# Given the following are disabled:
update-rc.d -f halt remove
update-rc.d -f reboot remove
update-rc.d -f sendsigs remove
update-rc.d -f umountfs remove
update-rc.d -f umountnfs remove
update-rc.d -f umountroot remove
update-rc.d -f networking remove
update-rc.d -f hwclock.sh remove


# Rest of packages
apt-get install -y atop htop sysstat strace
apt-get install -y iputils-ping net-tools iproute2 iptables links
apt-get install -y zsh bzip2 less rsync unzip vim zile pwgen apg rdiff-backup bc debsums unison
apt-get install -y xpra screen tmux terminology rxvt-unicode
apt-get install -y nethack-console
apt-get install -y sshfs encfs mosh autossh

# Python stuff
apt-get install -y ipython ipython3 python-gevent python-virtualenv fabric python-pip python-pip3
apt-get install -y python-pymongo python-scapy python-twisted

# Network analysis
apt-get install -y nmap tcpdump mtr ifstat aircrack-ng telnet netcat tinc

# Radio analysis
apt-get install -y rtl-sdr

# Emacs stuff.
apt-get install -y emacs emacs-goodies-el magit slime pymacs scala-mode-el python-mode
