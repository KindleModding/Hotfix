#!/bin/sh
# This script is needed if someone performs a cross-architecture downgrade/upgrade
# It selects the correct version of gandalf to run

ARCH="armel"
# Check if the Kindle is ARMHF or ARMEL
if ls /lib | grep ld-linux-armhf.so; then
    ARCH="armhf"
fi

# Yeah this is a weird command but I'm too lazy to test if it works without the "su -c"
/var/local/kmc/${ARCH}/bin/su su -c sh /var/local/kmc/hotfix/hotfix.sh