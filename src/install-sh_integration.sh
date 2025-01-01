HACKNAME="jb_sh_integration"

# Pull libOTAUtils for logging & progress handling
[ -f ./libotautils5 ] && source ./libotautils5


# Hack specific stuff
KMC_PERSISTENT_STORAGE="/var/local/kmc/"
logmsg "I" "install" "" "Creating KMC persistent storage directory"
make_mutable "${KMC_PERSISTENT_STORAGE}"
rm -rf "${KMC_PERSISTENT_STORAGE}"
mkdir -p "${KMC_PERSISTENT_STORAGE}"
chown root:root "${KMC_PERSISTENT_STORAGE}"
chmod g-s "${KMC_PERSISTENT_STORAGE}"

## Here we go :)
otautils_update_progressbar

ARCH="armel"

# Check if the Kindle is ARMHF or ARMEL
if ls /lib | grep ld-linux-armhf.so; then
    ARCH="armhf"
fi

logmsg "I" "arch_check" "" "Detected architecture - $ARCH"

otautils_update_progressbar

logmsg "I" "install" "" "Installing sh_integration"

otautils_update_progressbar

logmsg "I" "install" "" "Installing sh_integration_extractor"
cp -f $ARCH/sh_integration_extractor.so "${KMC_PERSISTENT_STORAGE}"
chmod a+rx "${KMC_PERSISTENT_STORAGE}sh_integration_extractor.so"

otautils_update_progressbar

logmsg "I" "install" "" "Installing sh_integration_launcher"
cp -f $ARCH/sh_integration_launcher "${KMC_PERSISTENT_STORAGE}"
chmod a+rx "${KMC_PERSISTENT_STORAGE}sh_integration_launcher"

otautils_update_progressbar

logmsg "I" "install" "" "Adding sh_integration into appreg"
logmsg "I" "install" "" "Modifying appreg.db"
sqlite3 /var/local/appreg.db ".read ./appreg_register_sh_integration.sql"

make_immutable "${KMC_PERSISTENT_STORAGE}"

otautils_update_progressbar

return 0