if [ ! -f "/PRE_GM_DEBUGGING_FEATURES_ENABLED__REMOVE_AT_GMC" ] ; then
    logmsg "I" "install_debugging_flag" "" "Creating the debugging flag file"
    make_mutable "/PRE_GM_DEBUGGING_FEATURES_ENABLED__REMOVE_AT_GMC"
    rm -rf "/PRE_GM_DEBUGGING_FEATURES_ENABLED__REMOVE_AT_GMC"
    touch "/PRE_GM_DEBUGGING_FEATURES_ENABLED__REMOVE_AT_GMC"
    make_immutable "/PRE_GM_DEBUGGING_FEATURES_ENABLED__REMOVE_AT_GMC"
fi