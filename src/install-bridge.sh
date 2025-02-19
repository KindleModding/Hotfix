#!/bin/sh
#
# Kindle Touch/PaperWhite JailBreak Bridge Installer
#
# $Id: install-bridge.sh 19298 2023-11-04 01:55:34Z NiLuJe $
#
##

HACKNAME="jb_bridge_1.13.0"

# Pull libOTAUtils for logging & progress handling
[ -f ./libotautils5 ] && source ./libotautils5


# Hack specific stuff
MKK_PERSISTENT_STORAGE="/var/local/mkk"
RP_PERSISTENT_STORAGE="/var/local/rp"
MKK_BACKUP_STORAGE="/mnt/us/mkk"
RP_BACKUP_STORAGE="/mnt/us/rp"
ARCH="armel"

# Check if the Kindle is ARMHF or ARMEL
if ls /lib | grep ld-linux-armhf.so; then
    ARCH="armhf"
fi

logmsg "I" "arch_check" "" "Detected architecture - $ARCH"

## Here we go :)
otautils_update_progressbar

# Install the bridge
logmsg "I" "install" "" "Installing the bridge"
mkdir -p "/var/local/system"
make_mutable "/var/local/system/fixup"
rm -rf "/var/local/system/fixup"
make_mutable "/var/local/system/onetimefixup"
rm -rf "/var/local/system/onetimefixup"
echo '#!/bin/sh' > /tmp/run_bridge.sh
echo '# Name: Run Hotfix' >> /tmp/run_bridge.sh
echo '# Author: HackerDude' >> /tmp/run_bridge.sh
echo '# Icon:' >> /tmp/run_bridge.sh
echo '# DontUseFBInk' >> /tmp/run_bridge.sh
echo '# V1.13.0' >> /tmp/run_bridge.sh
echo 'sh /var/local/mkk/bridge.sh' >> /tmp/run_bridge.sh
echo 'reboot' >> /tmp/run_bridge.sh
cp -f /tmp/run_bridge.sh /mnt/us/documents/

otautils_update_progressbar

# Install FBInk
logmsg "I" "install" "" "Installing fbink"
mkdir -p "/mnt/us/libkh/bin"
cp -f $ARCH/fbink "/mnt/us/libkh/bin/fbink"
chmod a+rx "/mnt/us/libkh/bin/fbink"

otautils_update_progressbar

# Make sure we have enough space left (>512KB) in /var/local first...
logmsg "I" "install" "" "checking amount of free storage space..."
if [ "$(df -k /var/local | tail -n 1 | awk '{ print $4; }')" -lt "512" ] ; then
    logmsg "C" "install" "code=1" "not enough space left in varlocal"
    # Cleanup & exit w/ prejudice
    rm -f bridge
    rm -f developer.keystore
    rm -f updater_keys.sqsh
    rm -f json_simple-1.1.jar
    rm -f gandalf
    rm -f bridge.conf
    return 1
fi

otautils_update_progressbar

# Make sure we have an up to date persistent copy of MKK...
logmsg "I" "install" "" "Creating MKK persistent storage directory"
make_mutable "${MKK_PERSISTENT_STORAGE}"
rm -rf "${MKK_PERSISTENT_STORAGE}"
mkdir -p "${MKK_PERSISTENT_STORAGE}"
chown root:root "${MKK_PERSISTENT_STORAGE}"
chmod g-s "${MKK_PERSISTENT_STORAGE}"

otautils_update_progressbar

logmsg "I" "install" "" "Storing combined developer keystore"
cp -f developer.keystore "${MKK_PERSISTENT_STORAGE}/developer.keystore"

otautils_update_progressbar

logmsg "I" "install" "" "Storing squashed developer keystore"
cp -f updater_keys.sqsh "${MKK_PERSISTENT_STORAGE}/updater_keys.sqsh"

otautils_update_progressbar

logmsg "I" "install" "" "Storing kindlet jailbreak"
cp -f json_simple-1.1.jar "${MKK_PERSISTENT_STORAGE}/json_simple-1.1.jar"

otautils_update_progressbar

logmsg "I" "install" "" "Storing gandalf"
cp -f $ARCH/gandalf "${MKK_PERSISTENT_STORAGE}/gandalf"

otautils_update_progressbar

logmsg "I" "install" "" "Setting up gandalf"
chown root:root "${MKK_PERSISTENT_STORAGE}/gandalf"
chmod a+rx "${MKK_PERSISTENT_STORAGE}/gandalf"
chmod +s "${MKK_PERSISTENT_STORAGE}/gandalf"
ln -sf "${MKK_PERSISTENT_STORAGE}/gandalf" "${MKK_PERSISTENT_STORAGE}/su"

otautils_update_progressbar

logmsg "I" "install" "" "Installing bridge job"
make_mutable "/etc/upstart/bridge.conf"
rm -rf "/etc/upstart/bridge.conf"
cp -f bridge.conf "/etc/upstart/bridge.conf"
chmod 0664 "/etc/upstart/bridge.conf"
make_immutable "/etc/upstart/bridge.conf"

otautils_update_progressbar

logmsg "I" "install" "" "Storing bridge job"
cp -af "/etc/upstart/bridge.conf" "${MKK_PERSISTENT_STORAGE}/bridge.conf"

otautils_update_progressbar

logmsg "I" "install" "" "Storing bridge script"

make_mutable "${MKK_PERSISTENT_STORAGE}"
cp -af bridge "${MKK_PERSISTENT_STORAGE}/bridge.sh"
chown root:root "${MKK_PERSISTENT_STORAGE}/bridge.sh"
chmod a+rx "${MKK_PERSISTENT_STORAGE}/bridge.sh"
make_immutable "${MKK_PERSISTENT_STORAGE}"

otautils_update_progressbar

logmsg "I" "install" "" "Setting up persistent RP"
make_mutable "${RP_PERSISTENT_STORAGE}"
rm -rf "${RP_PERSISTENT_STORAGE}"
mkdir -p "${RP_PERSISTENT_STORAGE}"
chown root:root "${RP_PERSISTENT_STORAGE}"
chmod g-s "${RP_PERSISTENT_STORAGE}"
for my_job in debrick cowardsdebrick ; do
    if [ -f "/etc/upstart/${my_job}.conf" ] ; then
        cp -af "/etc/upstart/${my_job}.conf" "${RP_PERSISTENT_STORAGE}/${my_job}.conf"
    fi
    if [ -f "/etc/upstart/${my_job}" ] ; then
        cp -af "/etc/upstart/${my_job}" "${RP_PERSISTENT_STORAGE}/${my_job}"
    fi
done
make_immutable "${RP_PERSISTENT_STORAGE}"

otautils_update_progressbar

logmsg "I" "install" "" "Setting up backup storage"
rm -rf "${MKK_BACKUP_STORAGE}"
mkdir -p "${MKK_BACKUP_STORAGE}"
rm -rf "${RP_BACKUP_STORAGE}"
mkdir -p "${RP_BACKUP_STORAGE}"
# Can't preserve symlinks & permissions on vfat, so do it the hard way ;).
for my_file in "${MKK_PERSISTENT_STORAGE}"/* ; do
	if [ -f "${my_file}" ] && [ ! -L "${my_file}" ] ; then
		cp -f "${my_file}" "${MKK_BACKUP_STORAGE}/"
	fi
done
for my_file in "${RP_PERSISTENT_STORAGE}"/* ; do
	if [ -f "${my_file}" ] && [ ! -L "${my_file}" ] ; then
		cp -f "${my_file}" "${RP_BACKUP_STORAGE}/"
	fi
done

otautils_update_progressbar

# NOTE: We don't actually *run* the bridge here, both because we want to make sure it actually works and runs as supposed to,
#       and also because it'd mount/unmount the rootfs, which might wreak havoc on the OTA updater.

# Cleanup
rm -f bridge
rm -f developer.keystore
rm -f updater_keys.sqsh
rm -f json_simple-1.1.jar
rm -f gandalf
rm -f bridge.conf
rm -f fbink
logmsg "I" "install" "" "done"

otautils_update_progressbar

return 0
