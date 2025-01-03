install_touch_update_key()
{
	logmsg "I" "install_touch_update_key" "" "Copying the jailbreak updater key"
	make_mutable "/etc/uks/pubdevkey01.pem"
	rm -rf "/etc/uks/pubdevkey01.pem"
	cat > "/etc/uks/pubdevkey01.pem" << EOF
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJn1jWU+xxVv/eRKfCPR9e47lP
WN2rH33z9QbfnqmCxBRLP6mMjGy6APyycQXg3nPi5fcb75alZo+Oh012HpMe9Lnp
eEgloIdm1E4LOsyrz4kttQtGRlzCErmBGt6+cAVEV86y2phOJ3mLk0Ek9UQXbIUf
rvyJnS2MKLG2cczjlQIDAQAB
-----END PUBLIC KEY-----
EOF
	# Harmonize permissions
	chown root:root "/etc/uks/pubdevkey01.pem"
	chmod 0644 "/etc/uks/pubdevkey01.pem"
	make_immutable "/etc/uks/pubdevkey01.pem"

	# Show some feedback
	print_jb_install_feedback
}

install_touch_update_key_squash()
{
	logmsg "I" "install_touch_update_key_squash" "" "Copying the jailbreak updater keystore"
	make_mutable "/etc/uks.sqsh"
	local my_loop="$(grep ' /etc/uks ' /proc/mounts | cut -f1 -d' ')"
    umount "${my_loop}"
    losetup -d "${my_loop}"
    cp -f "${MKK_PERSISTENT_STORAGE}/updater_keys.sqsh" "/etc/uks.sqsh"
    mount -o loop="${my_loop}",nodiratime,noatime -t squashfs "/etc/uks.sqsh" "/etc/uks"
    #make_immutable "/etc/uks.sqsh" # Breaks 12th gen

	# Show some feedback
	print_jb_squash_install_feedback
}

# Check if we need to do something with the OTA pubkey
if [ ! -f "/etc/uks.sqsh" ] ; then
	if [ ! -f "/etc/uks/pubdevkey01.pem" ] ; then
		# No jailbreak key, install it
		install_touch_update_key
	else
		# Jailbreak key found... Check it.
		if [ "$(md5sum "/etc/uks/pubdevkey01.pem" | awk '{ print $1; }')" != "7130ce39bb3596c5067cabb377c7a9ed" ] ; then
			# Unknown (?!) jailbreak key, install it
			install_touch_update_key
		fi
		if [ ! -O "/etc/uks/pubdevkey01.pem" ] || [ ! -G "/etc/uks/pubdevkey01.pem" ] ; then
			# Not our own? Make it so!
			install_touch_update_key
		fi
	fi
fi

# Check if we need to do something with the OTA keystore
if [ -f "/etc/uks.sqsh" ] && [ -f "${MKK_PERSISTENT_STORAGE}/updater_keys.sqsh" ] ; then
	# Check it.
	if [ "$(md5sum "/etc/uks.sqsh" | awk '{ print $1; }')" != "17b5ca595e70ffeee1424ed5e7f09c47" ] ; then
		# Unknown (?!) jailbreak keystore, install it
		install_touch_update_key_squash
	fi
	if [ ! -O "/etc/uks.sqsh" ] || [ ! -G "/etc/uks.sqsh" ] ; then
		# Not our own? Make it so!
		install_touch_update_key_squash
	fi
fi