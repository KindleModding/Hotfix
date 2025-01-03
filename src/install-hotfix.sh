#!/bin/sh

# Pull libOTAUtils for logging & progress handling
source ./libotautils5

cleanup()
{
    rm -rf kmc/
    rm -rf mkk/
    rm -f libotautils5
}

# Useeful vars
HOTFIX_VERSION="v2.0.0-Dev"
KMC_PERSISTENT_STORAGE="/var/local/kmc"
MKK_PERSISTENT_STORAGE="/var/local/mkk"
KMC_BACKUP_STORAGE="/mnt/us/kmc"
MKK_BACKUP_STORAGE="/mnt/us/mkk"
RP_BACKUP_STORAGE="/mnt/us/rp"
ARCH="armel"

# Check if the Kindle is ARMHF or ARMEL
if ls /lib | grep ld-linux-armhf.so; then
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
chmod a+rx "${KMC_PERSISTENT_STORAGE}/armel/*"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/armhf/*"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/hotfix.sh"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/run_hotfix.sh"

# Fix Gandalf permissions
chown root:root "${KMC_PERSISTENT_STORAGE}/armel/gandalf"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/armel/gandalf"
chmod +s "${KMC_PERSISTENT_STORAGE}/armel/gandalf"
chown root:root "${KMC_PERSISTENT_STORAGE}/armhf/gandalf"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/armhf/gandalf"
chmod +s "${KMC_PERSISTENT_STORAGE}/armhf/gandalf"


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
logmsg "I" "install" "" "Linking gandalf to mkk"
ln -sf "${KMC_PERSISTENT_STORAGE}/${ARCH}/gandalf" "${MKK_PERSISTENT_STORAGE}/gandalf"
logmsg "I" "install" "" "Linking arch-specific gandalf versions within kmc"
ln -sf "${KMC_PERSISTENT_STORAGE}/armhf/gandalf" "${KMC_PERSISTENT_STORAGE}/armhf/su"
ln -sf "${KMC_PERSISTENT_STORAGE}/armel/gandalf" "${KMC_PERSISTENT_STORAGE}/armel/su"

otautils_update_progressbar
logmsg "I" "install" "" "Setting up gandalf"
chown root:root "${MKK_PERSISTENT_STORAGE}/gandalf"
chmod a+rx "${MKK_PERSISTENT_STORAGE}/gandalf"
chmod +s "${MKK_PERSISTENT_STORAGE}/gandalf"
ln -sf "${MKK_PERSISTENT_STORAGE}/gandalf" "${MKK_PERSISTENT_STORAGE}/su"

# Install fbink
logmsg "I" "install" "" "Installing fbink"
mkdir -p "/mnt/us/libkh/bin"
cp -f "kmc/$ARCH/fbink" "/mnt/us/libkh/bin/fbink"
chmod a+rx "/mnt/us/libkh/bin/fbink"

otautils_update_progressbar

logmsg "I" "install" "" "Installing the hotfix booklet"

rm -f /mnt/us/documents/run_bridge.sh # Remove old runner
echo "${HOTFIX_VERSION}" > /mnt/us/documents/run_hotfix.run_hotfix

logmsg "I" "install" "" "Installing sh_integration"
ln -sf "${KMC_PERSISTENT_STORAGE}/${ARCH}/sh_integration_extractor.so" "${KMC_PERSISTENT_STORAGE}/lib/sh_integration_extractor.so"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/lib/sh_integration_extractor.so"

ln -sf "${KMC_PERSISTENT_STORAGE}/${ARCH}/sh_integration_extractor.so" "${KMC_PERSISTENT_STORAGE}/bin/sh_integration_launcher"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/bin/sh_integration_launcher"


logmsg "I" "install" "" "Modifying appreg.db"
sqlite3 /var/local/appreg.db ".read ./kmc/appreg_register_sh_integration.sql"
sqlite3 /var/local/appreg.db ".read ./kmc/appreg_register_hotfix_runner.sql"

cleanup()
logmsg "I" "install" "" "done"

otautils_update_progressbar
return 0