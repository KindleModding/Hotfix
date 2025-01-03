# Check if we need to do something with the Kindlet developer keystore
if [ -f "${MKK_PERSISTENT_STORAGE}/developer.keystore" ] ; then
	# No developer keystore, install it                       		OR  The developer keystore doesn't match - NOTE: This *will* mess with real, official developer keystores. Not that we really care about it, but it should be noted ;).
	if [ ! -f "/var/local/java/keystore/developer.keystore" ] || \
		[ "$(md5sum "/var/local/java/keystore/developer.keystore" | awk '{ print $1; }')" != "$(md5sum "${MKK_PERSISTENT_STORAGE}/developer.keystore" | awk '{ print $1; }')" ] ; then
		
		# Install the kindlet keystore
		logmsg "I" "install_mkk_dev_keystore" "" "Copying the kindlet keystore"
		# We shouldn't need to do anything specific to read/write /var/local
		if [ "$(df -k /var/local | tail -n 1 | awk '{ print $4; }')" -lt "512" ] ; then
			# Hu ho... Keep track of this...
			VARLOCAL_OOS="true"
			logmsg "W" "install_mkk_dev_keystore" "" "Failed to copy the kindlet keystore: not enough space left on device"
		else
			# NOTE: This might have gone poof on newer devices without Kindlet support, so, create it as needed
			mkdir -p "/var/local/java/keystore"
			cp -f "${MKK_PERSISTENT_STORAGE}/developer.keystore" "/var/local/java/keystore/developer.keystore"
		fi

		# Show some feedback
		print_mkk_dev_keystore_feedback
	fi
fi