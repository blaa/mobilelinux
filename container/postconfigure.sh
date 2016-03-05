#!/bin/bash

# Optional helper for post-creation configuration; to be run inside the container.
# You should probably alter it for your needs and then keep handy.
# Set apt-get mirror correctly before installing this many packages.
# At minimum - change user name and strip package list.

# Username to create
NEWUSER=bla

##
# /etc config tracking as early as possible
apt-get install -y --no-install-recommends git 
git config --global user.name "Administrator"
git config --global user.email 'admin@localhost'

apt-get install --no-install-recommends -y etckeeper

##
# Basic setup

# Mostly for neat df output.
cp /proc/mounts /etc/mtab

# Timezone
cd /etc
cp /usr/share/zoneinfo/Europe/Warsaw localtime

# Add basic user
adduser $NEWUSER

# Create android related groups
addgroup --gid 1028 sdcard_rw
addgroup --gid 1005 and_audio
addgroup --gid 3003 and_inet

adduser $NEWUSER sdcard_rw
adduser $NEWUSER and_audio
adduser $NEWUSER and_inet

cleanup_rc () {
    # Command used to start everything automatically:
    # /etc/init.d/rc 2
    # Stop everything:
    # /etc/init.d/rc 0
    # Given the following are disabled: 
    update-rc.d -f halt remove
    update-rc.d -f reboot remove
    update-rc.d -f sendsigs remove
    update-rc.d -f umountfs remove
    update-rc.d -f umountnfs.sh remove
    update-rc.d -f umountroot remove
    update-rc.d -f networking remove
    update-rc.d -f hwclock.sh remove
}

cleanup_rc

# Rest of packages
apt-get install -y atop htop sysstat strace
apt-get install -y iputils-ping net-tools iproute2 iptables links
apt-get install -y zsh bzip2 less rsync unzip vim zile pwgen apg rdiff-backup bc debsums unison
apt-get install -y usbutils kmod
apt-get install -y screen tmux terminology 
apt-get install -y nethack-console 
apt-get install -y sshfs encfs mosh autossh

# X stuff
apt-get install -y xpra tightvncserver rxvt-unicode

# Python stuff
apt-get install -y ipython ipython3 python-gevent python-virtualenv python3-virtualenv fabric python-pip python3-pip
apt-get install -y python-pymongo python-scapy python-twisted

# Network tools / analysis
apt-get install -y nmap tcpdump mtr ifstat aircrack-ng telnet netcat tinc tor bind9-host

# Radio analysis - this pulls a lot of packages
apt-get install -y rtl-sdr gqrx-sdr 

# Emacs stuff.
apt-get install -y emacs emacs-goodies-el magit slime pymacs scala-mode-el python-mode

apt-get purge exim4-base sane-utils
apt-get -u autoremove
apt-get clean

cleanup_rc

# Stuff above takes 2GB 

# Trivia
cat > /etc/motd <<EOF

Adventurer, welcome to Mobile Linux.

EOF

# Locales
if ! egrep -q '^pl_PL' /etc/locale.gen; then
    echo "pl_PL.UTF-8 UTF-8" >> /etc/locale.gen
    echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
fi

# Create a handy script to cut latency from ssh connections.
cat > /root/disable_wifi_powersave.sh <<EOF
#!/bin/bash
iw dev wlan0 set power_save off
EOF
chmod a+x /root/disable_wifi_powersave.sh
