setup_gandalf()
{
	# Fix Gandalf permissions
	logmsg "I" "install" "" "Fixing KMC Gandalf permissions"
	for gandalf_arch in armel armhf; do
		make_mutable "${KMC_PERSISTENT_STORAGE}/${gandalf_arch}/bin/gandalf"
		chown root:root "${KMC_PERSISTENT_STORAGE}/${gandalf_arch}/bin/gandalf"
		chmod a+rx "${KMC_PERSISTENT_STORAGE}/${gandalf_arch}/bin/gandalf"
		chmod +s "${KMC_PERSISTENT_STORAGE}/${gandalf_arch}/bin/gandalf"
		make_immutable "${KMC_PERSISTENT_STORAGE}/${gandalf_arch}/bin/gandalf"
	done

	make_mutable "${KMC_PERSISTENT_STORAGE}"
	logmsg "I" "setup_gandalf" "" "Setting up gandalf... you shall not pass!"
	logmsg "I" "install" "" "Linking gandalf to MKK"

	make_mutable "${MKK_PERSISTENT_STORAGE}"
	rm -f "${MKK_PERSISTENT_STORAGE}/gandalf"
	ln -sf "${KMC_PERSISTENT_STORAGE}/bin/gandalf" "${MKK_PERSISTENT_STORAGE}/gandalf"
	ln -sf "${MKK_PERSISTENT_STORAGE}/gandalf" "${MKK_PERSISTENT_STORAGE}/su"
	make_immutable "${MKK_PERSISTENT_STORAGE}"

	# Show some feedback
	print_gandalf_feedback
}

# Check if we need to do something with Gandalf
if [ -f "${MKK_PERSISTENT_STORAGE}/gandalf" ] ; then
	# NOTE: The bridge job already does this, too.
	if [ ! -O "${MKK_PERSISTENT_STORAGE}/gandalf" ] || [ ! -G "${MKK_PERSISTENT_STORAGE}/gandalf" ] ; then
		setup_gandalf
	fi
	if [ ! -x "${MKK_PERSISTENT_STORAGE}/gandalf" ] ; then
		setup_gandalf
	fi
	if [ ! -u "${MKK_PERSISTENT_STORAGE}/gandalf" ] ; then
		setup_gandalf
	fi
	if [ ! -h "${MKK_PERSISTENT_STORAGE}/su" ] ; then
		setup_gandalf
	fi
	if [ ! -x "${MKK_PERSISTENT_STORAGE}/su" ] ; then
		setup_gandalf
	fi
	# NOTE: This will actually end up a NOOP, because -O & -G tests don't behave all that well with symlinks...
	if [ ! -O "${MKK_PERSISTENT_STORAGE}/su" ] || [ ! -G "${MKK_PERSISTENT_STORAGE}/su" ] ; then
		setup_gandalf
	fi
fi