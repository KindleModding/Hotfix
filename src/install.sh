#!/bin/sh

# Pull libOTAUtils for logging & progress handling
source ./libotautils6

cleanup()
{
    rm -f kmc.tar
    rm -f mkk.tar
    rm -f libotautils6
}

HACKNAME="HAKT"
logmsg "I" "arch_check" "" "Detected architecture - $ARCH"
logmsg "I" "hakt_installer" "" "Installing Hotfix (previously bridge)."

###
## Here we go :)
###
otautils_update_progressbar

# Make sure we have enough space left (>512KB) in /var/local first...
logmsg "I" "install" "" "checking amount of free storage space..."
if [ "$(df -k /var/local | tail -n 1 | awk '{ print $4; }')" -lt "$(($(du kmc.tar | cut -f1) + $(du mkk.tar | cut -f1)))" ] ; then
    logmsg "C" "install" "code=1" "not enough space left in varlocal"
    logmsg "C" "storage_error" "Needed: $(($(du kmc.tar | cut -f1) + $(du mkk.tar | cut -f1)))"
    logmsg "C" "storage_error" "Available: $(df -k /var/local | tail -n 1 | awk '{ print $4; }')"
    cleanup()

    otautils_die "Not enough space left on device!"
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
logmsg "I" "install" "" "Unpacking persistent storage data"
tar -xf mkk.tar -C "${MKK_PERSISTENT_STORAGE}"
tar -xf kmc.tar -C "${KMC_PERSISTENT_STORAGE}"

###
# Fix permissions for KMC (MKK doesn't need this)
###
otautils_update_progressbar
logmsg "I" "install" "" "Fixing KMC permissions"
chmod 0664 "${KMC_PERSISTENT_STORAGE}/kmc.conf"
chmod -R a+rx ${KMC_PERSISTENT_STORAGE}"/armel/*"
chmod -R a+rx ${KMC_PERSISTENT_STORAGE}"/armhf/*"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/hotfix/hotfix.sh"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/hotfix/run_hotfix.sh"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/hotfix/libhotfixutils"
chmod a+rx ${KMC_PERSISTENT_STORAGE}"/hotfix/jobs/*"

logmsg "I" "banner" "" ""
logmsg "I" "banner" "" ""
logmsg "I" "banner" "" "HAKT INSTALLER (${HOTFIX_VERSION})"
logmsg "I" "banner" "" "Installing on arch=${ARCH}"
logmsg "I" "banner" "" "Based on NiLuJe's hotfix & hotfix installer"
logmsg "I" "banner" "" "Created by HackerDude"
logmsg "I" "banner" "" "Special thanks to martysh & ThatOnePerson for beta testing this!"
logmsg "I" "banner" "" ""
logmsg "I" "banner" "" ""

# Fix Gandalf permissions
logmsg "I" "install" "" "Fixing KMC Gandalf permissions"
for gandalf_arch in armel armhf; do
    make_mutable "${KMC_PERSISTENT_STORAGE}/${gandalf_arch}/bin/gandalf"
    chown root:root "${KMC_PERSISTENT_STORAGE}/${gandalf_arch}/bin/gandalf"
    chmod a+rx "${KMC_PERSISTENT_STORAGE}/${gandalf_arch}/bin/gandalf"
    chmod +s "${KMC_PERSISTENT_STORAGE}/${gandalf_arch}/bin/gandalf"
    make_immutable "${KMC_PERSISTENT_STORAGE}/${gandalf_arch}/bin/gandalf"
done

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
make_mutable "/etc/upstart/bridge.conf"
rm -rf "/etc/upstart/bridge.conf" # Delete OLD bridge upstart job (Our KMC job is much neater)
rm -rf "/etc/upstart/kmc.conf"
cp -f "${KMC_PERSISTENT_STORAGE}/hotfix/kmc.conf" "/etc/upstart/kmc.conf"
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
cp -f "${KMC_PERSISTENT_STORAGE}/${ARCH}/bin/fbink" "/mnt/us/libkh/bin/fbink"
chmod a+rx "/mnt/us/libkh/bin/fbink"

otautils_update_progressbar

logmsg "I" "install_dispatch" "" "Copying the dispatch script"
make_mutable "/usr/bin/logThis.sh"
rm -rf "/usr/bin/logThis.sh"
cp -f "${MKK_PERSISTENT_STORAGE}/dispatch.sh" "/usr/bin/logThis.sh"
chmod 0755 "/usr/bin/logThis.sh"
make_immutable "/usr/bin/logThis.sh"

otautils_update_progressbar

logmsg "I" "install" "" "Installing the hotfix booklet"
rm -f /mnt/us/documents/run_bridge.sh # Remove old runner
rm -f /mnt/us/documents/run_hotfix.run_hotfix # One person got a beta with this lol
echo "${HOTFIX_VERSION}" > "/mnt/us/documents/Run Hotfix.run_hotfix"


logmsg "I" "install" "" "Modifying appreg.db"
sqlite3 /var/local/appreg.db ".read ${KMC_PERSISTENT_STORAGE}/hotfix/appreg_register_sh_integration.sql"
sqlite3 /var/local/appreg.db ".read ${KMC_PERSISTENT_STORAGE}/hotfix/appreg_register_hotfix_runner.sql"

cleanup()
make_immutable "${MKK_PERSISTENT_STORAGE}"
logmsg "I" "install" "" "done"

otautils_update_progressbar
sleep 5
return 0