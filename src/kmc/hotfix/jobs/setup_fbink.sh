logmsg "I" "install" "" "Installing fbink"
mkdir -p "/mnt/us/libkh/bin"
rm -f /mnt/us/libkh/bin/fbink
cp -f "${KMC_PERSISTENT_STORAGE}/bin/fbink" "/mnt/us/libkh/bin/fbink"
chmod a+rx "/mnt/us/libkh/bin/fbink"