if [ ! -f "/MNTUS_EXEC" ] ; then
    logmsg "I" "install_mntus_exec_flag" "" "Creating the mntus exec flag file"
    make_mutable "/MNTUS_EXEC"
    rm -rf "/MNTUS_EXEC"
    touch "/MNTUS_EXEC"
    make_immutable "/MNTUS_EXEC"
fi