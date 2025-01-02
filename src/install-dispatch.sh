#!/bin/sh
#
# Kindle Oasis Dispatch Installer
#
# $Id: install-dispatch.sh 19298 2023-11-04 01:55:34Z NiLuJe $
#
##

HACKNAME="jb_dispatch"

# Pull libOTAUtils for logging & progress handling
[ -f ./libotautils5 ] && source ./libotautils5


# Hack specific stuff
MKK_PERSISTENT_STORAGE="/var/local/mkk"
MKK_BACKUP_STORAGE="/mnt/us/mkk"


## Here we go :)
otautils_update_progressbar

# Install the dispatch
logmsg "I" "install" "" "Installing the dispatch"
make_mutable "/usr/bin/logThis.sh"
cp -f dispatch "/usr/bin/logThis.sh"
chmod a+rx "/usr/bin/logThis.sh"
make_immutable "/usr/bin/logThis.sh"


otautils_update_progressbar

# Make sure we have enough space left (>512KB) in /var/local first...
logmsg "I" "install" "" "checking amount of free storage space..."
if [ "$(df -k /var/local | tail -n 1 | awk '{ print $4; }')" -lt "512" ] ; then
    logmsg "C" "install" "code=1" "not enough space left in varlocal"
    # Cleanup & exit w/ prejudice
    rm -f dispatch
    return 1
fi

otautils_update_progressbar


# Make sure we have an up to date persistent copy of MKK...
logmsg "I" "install" "" "Creating MKK persistent storage directory"
make_mutable "${MKK_PERSISTENT_STORAGE}"
mkdir -p "${MKK_PERSISTENT_STORAGE}"

otautils_update_progressbar


logmsg "I" "install" "" "Storing dispatch script"
#cp -af "/usr/bin/logThis.sh" "${MKK_PERSISTENT_STORAGE}/dispatch.sh"
# I don't know why this fixes it, I don't want to know why this fixes it
# But heed my words
# It does NOT work if you copy it directly from /usr/bin/logThis.sh
cp -f dispatch "${MKK_PERSISTENT_STORAGE}/dispatch.sh"
chmod a+rx "${MKK_PERSISTENT_STORAGE}/dispatch.sh"
make_immutable "${MKK_PERSISTENT_STORAGE}"

otautils_update_progressbar


logmsg "I" "install" "" "Setting up backup storage"
# NOTE: Don't wreck the job the bridge install has just done (we're guaranteed to run *after* the bridge install).
mkdir -p "${MKK_BACKUP_STORAGE}"
cp -f "${MKK_PERSISTENT_STORAGE}/dispatch.sh" "${MKK_BACKUP_STORAGE}/dispatch.sh"

otautils_update_progressbar


# Cleanup
rm -f dispatch
logmsg "I" "install" "" "done"

otautils_update_progressbar

return 0
