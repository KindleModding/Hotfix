# Check if we need to do something with the KMC job
if [ -f "${KMC_PERSISTENT_STORAGE}/hotfix/kmc.conf" ] ; then
	if [ ! -f "/etc/upstart/kmc.conf" ] ; then
		make_mutable "/etc/upstart/kmc.conf"
		rm -rf "/etc/upstart/kmc.conf"
		cp -f "${KMC_PERSISTENT_STORAGE}/hotfix/kmc.conf" "/etc/upstart/kmc.conf"
		chmod 0664 "/etc/upstart/kmc.conf"
		make_immutable "/etc/upstart/kmc.conf"
	fi
fi