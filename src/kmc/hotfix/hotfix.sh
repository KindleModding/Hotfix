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

logmsg "I" "hotfix" "" "Hotfix Complete! Restarting GUI."
sleep 3 # So they can read what's about to happen
restart lab126_gui &
sleep 3
/var/local/kmc/bin/fbink -y 4 -m -S 7 "Restarting GUI"
/var/local/kmc/bin/fbink -y 6 -m -S 7 "Please Wait..."
/var/local/kmc/bin/fbink -y 17 -p -S 3 "(Kindles are slow lol)  "