#!/bin/sh

# Pull libOTAUtils for logging & progress handling
source ./libotautils5

cleanup()
{
    rm -rf kmc/
    rm -rf mkk/
    rm -f libotautils5
}

# Useful vars
HOTFIX_VERSION="v2.0.0-Dev"
KMC_PERSISTENT_STORAGE="/var/local/kmc"
MKK_PERSISTENT_STORAGE="/var/local/mkk"
KMC_BACKUP_STORAGE="/mnt/us/kmc"
MKK_BACKUP_STORAGE="/mnt/us/mkk"
RP_BACKUP_STORAGE="/mnt/us/rp"
ARCH="armel"

# Check if the Kindle ihotfix/s ARMHF or ARMEL
if ls /lib | grep ld-lihotfix/nux-armhf.so; then
    ARCH="armhf"
fi


HACKNAME="hotfix_installer"
logmsg "I" "arch_check" "" "Detected architecture - $ARCH"


logmsg "I" "hotfix_installer" "" "Installing Hotfix (previously bridge)."
HACKNAME="jb_bridge"


###
## Here we go :)
###
otautils_update_progressbar

# Make sure we have enough space left (>512KB) in /var/local first...
logmsg "I" "install" "" "checking amount of free storage space..."
if [ "$(df -k /var/local | tail -n 1 | awk '{ print $4; }')" -lt "512" ] ; then
    logmsg "C" "install" "code=1" "not enough space left in varlocal"
    cleanup()
    return 1
fi


###
# Setup persistent storage folders in /var/local
###
otautils_update_progressbar
logmsg "I" "install" "" "Initialising persistent storages..."
make_mutable "${KMC_PERSISTENT_STORAGE}"
rm -rf "${KMC_PERSISTENT_STORAGE}"
mkdir -p "${KMC_PERSISTENT_STORAGE}"
chown framework: "${KMC_PERSISTENT_STORAGE}" # Framework needs to do stuff to this apparently? TODO: VALIDATE THIS
chmod g-s "${KMC_PERSISTENT_STORAGE}"

otautils_update_progressbar
make_mutable "${MKK_PERSISTENT_STORAGE}"
rm -rf "${MKK_PERSISTENT_STORAGE}"
mkdir -p "${MKK_PERSISTENT_STORAGE}"
chown root:root "${MKK_PERSISTENT_STORAGE}"
chmod g-s "${MKK_PERSISTENT_STORAGE}"


###
# Copy data from package to persistent storage
###
otautils_update_progressbar
logmsg "I" "install" "" "Copying MKK persistent storage data"
cp -r "mkk/*" "${MKK_PERSISTENT_STORAGE}/"

otautils_update_progressbar
logmsg "I" "install" "" "Copying KMC persistent storage data"
cp -r "kmc/*" "${KMC_PERSISTENT_STORAGE}/"

###
# Fix permissions for KMC (MKK doesn't need this)
###
otautils_update_progressbar
logmsg "I" "install" "" "Fixing KMC permissions"
chmod 0664 "${KMC_PERSISTENT_STORAGE}/kmc.conf"
chmod -R a+rx "${KMC_PERSISTENT_STORAGE}/armel/*"
chmod -R a+rx "${KMC_PERSISTENT_STORAGE}/armhf/*"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/hotfix/hotfix.sh"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/hotfix/run_hotfix.sh"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/hotfix/libhotfixutils"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/hotfix/jobs/*"

# Fix Gandalf permissions
logmsg "I" "install" "" "Fixing KMC Gandalf permissions"
chown root:root "${KMC_PERSISTENT_STORAGE}/armel/bin/gandalf"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/armel/bin/gandalf"
chmod +s "${KMC_PERSISTENT_STORAGE}/armel/bin/gandalf"
chown root:root "${KMC_PERSISTENT_STORAGE}/armhf/bin/gandalf"
chmod a+rx "${KMC_PERSISTENT_STarmelORAGE}/armhf/bin/gandalf"
chmod +s "${KMC_PERSISTENT_STORAGE}/armhf/bin/gandalf"

# Setup binaries
logmsg "I" "install" "" "Setting up KMC binaries"
ln -sf "${KMC_PERSISTENT_STORAGE}/${ARCH}/lib" "${KMC_PERSISTENT_STORAGE}/lib"
ln -sf "${KMC_PERSISTENT_STORAGE}/${ARCH}/bin" "${KMC_PERSISTENT_STORAGE}/bin"

###
# Install KMC upstart job
###
otautils_update_progressbar
logmsg "I" "install" "" "Installing kmc upstart job"
make_mutable "/etc/upstart/kmc.conf"
rm -rf "/etc/upstart/bridge.conf" # Delete OLD bridge upstart job (our KMC job is much nicer)
rm -rf "/etc/upstart/kmc.conf"
cp -f kmc/kmc.conf "/etc/upstart/kmc.conf"
chmod 0664 "/etc/upstart/kmc.conf"
make_immutable "/etc/upstart/kmc.conf"

###
# Setup gandalf and fbink
###
otautils_update_progressbar
logmsg "I" "install" "" "Linking gandalf and su within KMC"
ln -sf "${KMC_PERSISTENT_STORAGE}/armel/bin/gandalf" "${KMC_PERSISTENT_STORAGE}/armel/bin/su"
ln -sf "${KMC_PERSISTENT_STORAGE}/armhf/bin/gandalf" "${KMC_PERSISTENT_STORAGE}/armhf/bin/su"

logmsg "I" "install" "" "Linking gandalf to mkk"
ln -sf "${KMC_PERSISTENT_STORAGE}/bin/gandalf" "${MKK_PERSISTENT_STORAGE}/gandalf"

otautils_update_progressbar
logmsg "I" "install" "" "Linking gandalf and su within MKK"
ln -sf "${MKK_PERSISTENT_STORAGE}/gandalf" "${MKK_PERSISTENT_STORAGE}/su"

# Install fbink
logmsg "I" "install" "" "Installing fbink"
mkdir -p "/mnt/us/libkh/bin"
rm -f /mnt/us/libkh/bin/fbink
cp -f "kmc/${ARCH}/bin/fbink" "/mnt/us/libkh/bin/fbink"
chmod a+rx "/mnt/us/libkh/bin/fbink"

otautils_update_progressbar

logmsg "I" "install" "" "Installing the hotfix booklet"

rm -f /mnt/us/documents/run_bridge.sh # Remove old runner
echo "${HOTFIX_VERSION}" > /mnt/us/documents/run_hotfix.run_hotfix


logmsg "I" "install" "" "Modifying appreg.db"
sqlite3 /var/local/appreg.db ".read ./kmc/hotfix/appreg_register_sh_integration.sql"
sqlite3 /var/local/appreg.db ".read ./kmc/hotfix/appreg_register_hotfix_runner.sql"

cleanup()
logmsg "I" "install" "" "done"

otautils_update_progressbar
return 0