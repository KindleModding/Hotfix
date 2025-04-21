###
# Fix permissions for KMC (MKK doesn't need this)
###
logmsg "I" "install" "" "Fixing KMC permissions"
make_mutable "${KMC_PERSISTENT_STORAGE}/armel/bin/gandalf"
make_mutable "${KMC_PERSISTENT_STORAGE}/armhf/bin/gandalf"
chmod -R a+rx "${KMC_PERSISTENT_STORAGE}"/armel/*
chmod -R a+rx "${KMC_PERSISTENT_STORAGE}"/armhf/*
chmod a+rx "${KMC_PERSISTENT_STORAGE}/hotfix/hotfix.sh"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/hotfix/run_hotfix.sh"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/hotfix/libhotfixutils"
chmod a+rx "${KMC_PERSISTENT_STORAGE}"/hotfix/jobs/*
chmod 0664 "${KMC_PERSISTENT_STORAGE}/hotfix/kmc.conf"

# Fix Gandalf permissions
logmsg "I" "install" "" "Fixing KMC gandalf permissions"
chown root:root "${KMC_PERSISTENT_STORAGE}/armel/bin/gandalf"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/armel/bin/gandalf"
chmod +s "${KMC_PERSISTENT_STORAGE}/armel/bin/gandalf"
chown root:root "${KMC_PERSISTENT_STORAGE}/armhf/bin/gandalf"
chmod a+rx "${KMC_PERSISTENT_STORAGE}/armhf/bin/gandalf"
chmod +s "${KMC_PERSISTENT_STORAGE}/armhf/bin/gandalf"
make_immutable "${KMC_PERSISTENT_STORAGE}/armel/bin/gandalf"
make_immutable "${KMC_PERSISTENT_STORAGE}/armhf/bin/gandalf"

logmsg "I" "install" "" "Installing KMC binaries for ${ARCH}"
rm -rf "${KMC_PERSISTENT_STORAGE}/lib"
rm -rf "${KMC_PERSISTENT_STORAGE}/bin"
ln -sf "${KMC_PERSISTENT_STORAGE}/${ARCH}/lib" "${KMC_PERSISTENT_STORAGE}/lib"
ln -sf "${KMC_PERSISTENT_STORAGE}/${ARCH}/bin" "${KMC_PERSISTENT_STORAGE}/bin"
# Since the links to these binaries are SOFT links, no additional copying/linking is required
