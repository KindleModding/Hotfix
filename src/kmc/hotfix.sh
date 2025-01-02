#!/bin/sh


# Pull some helper functions for logging
source /etc/upstart/functions
LOG_DOMAIN="jb_hotfix"

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

# Install the dispatch
logmsg "I" "install" "" "Installing the dispatch"
make_mutable "/usr/bin/logThis.sh"
cp -f dispatch "/usr/bin/logThis.sh"
chmod a+rx "/usr/bin/logThis.sh"
make_immutable "/usr/bin/logThis.sh"
