# Check if we need to do something with the Kindlet JB
if [ -f "${MKK_PERSISTENT_STORAGE}/json_simple-1.1.jar" ] ; then
	# Kindlet JB doesn't match, install it
	if [ "$(md5sum "/opt/amazon/ebook/lib/json_simple-1.1.jar" | awk '{ print $1; }')" != "$(md5sum "${MKK_PERSISTENT_STORAGE}/json_simple-1.1.jar" | awk '{ print $1; }')" ] ; then
		logmsg "I" "install_mkk_kindlet_jb" "" "Copying the kindlet jailbreak"
		cp -f "${MKK_PERSISTENT_STORAGE}/json_simple-1.1.jar" "/opt/amazon/ebook/lib/json_simple-1.1.jar"
		chmod 0664 "/opt/amazon/ebook/lib/json_simple-1.1.jar"
	fi
fi