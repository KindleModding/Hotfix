# Ensure we have a dispatch script
if [ -f "${MKK_PERSISTENT_STORAGE}/dispatch.sh" ] ; then
	# If logThis.sh isn't installed   OR   It isn't our Dispatch script
	if [ ! -f "/usr/bin/logThis.sh" ] || [ ! grep -q "Dispatch" "/usr/bin/logThis.sh" ] ; then
		logmsg "I" "install_dispatch" "" "Copying the dispatch script"
		make_mutable "/usr/bin/logThis.sh"
		rm -rf "/usr/bin/logThis.sh"
		cp -f "${MKK_PERSISTENT_STORAGE}/dispatch.sh" "/usr/bin/logThis.sh"
		chmod 0755 "/usr/bin/logThis.sh"
		make_immutable "/usr/bin/logThis.sh"
	fi
fi