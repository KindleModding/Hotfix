#!/bin/sh
# This script is needed if someone performs a cross-architecture downgrade/upgrade
# It selects the correct version of gandalf to run

ARCH="armel"
# Check if the Kindle is ARMHF or ARMEL
if [ ls /lib | grep -q ld-linux-armhf.so ]; then
    ARCH="armhf"
fi

/var/local/kmc/${ARCH}/bin/su -c "sh /var/local/kmc/hotfix/hotfix.sh"