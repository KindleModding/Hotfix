#!/bin/sh


# Pull some helper functions and the such
source /etc/upstart/functions
source /var/local/kmc/libhotfixutils
LOG_DOMAIN="jb_hotfix"

# Here we go...
logmsg "I" "main" "" "Running HAKT Hotfix (${HOTFIX_VERSION})"

logmsg "I" "tools" "" "Mounting root as RW"
mntroot rw

for JOB in ${KMC_PERSISTENT_STORAGE}/hotfix/jobs/*.sh ; do
    logmsg "I" "jobrunner" "" "Running job: ${JOB}"
    source "$(realpath $JOB)"
done