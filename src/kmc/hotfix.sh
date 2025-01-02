#!/bin/sh


# Pull some helper functions for logging
source /etc/upstart/functions
LOG_DOMAIN="jb_hotfix"

# Setup environment
ROOTPART="$(rdev | awk '{ print $1; }')" # Hotfix is ran as a booklet, we are ALWAYS running from main

KMC_PERSISTENT_STORAGE="/var/local/kmc"
MKK_PERSISTENT_STORAGE="/var/local/mkk"
RP_PERSISTENT_STORAGE="/var/local/rp"
KMC_BACKUP_STORAGE="/mnt/us/kmc"
MKK_BACKUP_STORAGE="/mnt/us/mkk"
ARCH="armel"
# Check if the Kindle is ARMHF or ARMEL
if ls /lib | grep ld-linux-armhf.so; then
    ARCH="armhf"
fi

logmsg()
{
	f_log "${1}" "${LOG_DOMAIN}" "${2}" "${3}" "${4}"
}

# Helper functions
RW=""
mount_rw() {
	if [ -z "${RW}" ] ; then
		RW="yes"
		mount -o rw,remount /
	fi
}

mount_ro() {
	if [ -n "${RW}" ] ; then
		RW=""
		mount -o ro,remount /
	fi
}

make_mutable() {
	local my_path="${1}"
	# NOTE: Can't do that on symlinks, hence the hoop-jumping...
	if [ -d "${my_path}" ] ; then
		find "${my_path}" -type d -exec chattr -i '{}' \;
		find "${my_path}" -type f -exec chattr -i '{}' \;
	elif [ -f "${my_path}" ] ; then
		chattr -i "${my_path}"
	fi
}

make_immutable() {
	local my_path="${1}"
	if [ -d "${my_path}" ] ; then
		find "${my_path}" -type d -exec chattr +i '{}' \;
		find "${my_path}" -type f -exec chattr +i '{}' \;
	elif [ -f "${my_path}" ] ; then
		chattr +i "${my_path}"
	fi
}

# Here we go...
logmsg "I" "main" "" "i can fix this (r${BRIDGE_REV})"

###
# Re-link binaries to current architecture (THIS CAN CHANGE LOL)
###
logmsg "I" "install" "" "Linking gandalf to MKK"
rm -f "${MKK_PERSISTENT_STORAGE}/gandalf"
ln -sf "${KMC_PERSISTENT_STORAGE}/${ARCH}/gandalf" "${MKK_PERSISTENT_STORAGE}/gandalf"

logmsg "I" "install" "" "Setting up gandalf"
chown root:root "${MKK_PERSISTENT_STORAGE}/gandalf"
chmod a+rx "${MKK_PERSISTENT_STORAGE}/gandalf"
chmod +s "${MKK_PERSISTENT_STORAGE}/gandalf"
ln -sf "${MKK_PERSISTENT_STORAGE}/gandalf" "${MKK_PERSISTENT_STORAGE}/su"

# Same for fbink
logmsg "I" "install" "" "Installing fbink"
mkdir -p "/mnt/us/libkh/bin"
rm -f /mnt/us/libkh/bin/fbink
cp -f "kmc/$ARCH/fbink" "/mnt/us/libkh/bin/fbink"
chmod a+rx "/mnt/us/libkh/bin/fbink"
###


# Install the dispatch
logmsg "I" "install" "" "Installing the dispatch"
make_mutable "/usr/bin/logThis.sh"
cp -f dispatch "/usr/bin/logThis.sh"
chmod a+rx "/usr/bin/logThis.sh"
make_immutable "/usr/bin/logThis.sh"
