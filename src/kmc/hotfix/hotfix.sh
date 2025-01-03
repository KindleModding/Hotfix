#!/bin/sh


# Pull some helper functions and the such
source /etc/upstart/functions
source /var/local/kmc/hotfix/libhotfixutils
LOG_DOMAIN="jb_hotfix"

# Here we go...
logmsg "I" "hotfix" "" "Running Universal Hotfix (${HOTFIX_VERSION})"

logmsg "I" "hotfix" "" "Mounting root as RW"
mntroot rw

for JOB in ${KMC_PERSISTENT_STORAGE}/hotfix/jobs/*.sh ; do
    logmsg "I" "jobrunner" "" "Running job: $(basename $JOB)"
    source "$(realpath $JOB)"
done

logmsg "I" "hotfix" "" "Mounting root as RO"
mntroot ro

logmsg "I" "hotfix" "" "Hotfix Complete! You may need to reboot."