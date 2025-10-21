if [ -f "/usr/share/app/kpp_sys_cmds.json" ] ; then
	if ! grep -q "logThis.sh" "/usr/share/app/kpp_sys_cmds.json" ; then
		logmsg "I" "install_log_kpp" "" "Patching in the dispatch command for kpp"
        # KPP (React, new UI) (sys)
        sed -e '/^{/a\' -e '    ";log" : "/usr/bin/logThis.sh",' -i "/usr/share/app/kpp_sys_cmds.json"
	fi

	if ! grep -q "KMCLog.sh" "/usr/share/app/kpp_sys_cmds.json" ; then
		logmsg "I" "install_log_kpp" "" "Patching in the KMC log command for kpp"
        sed -e '/^{/a\' -e '    ";kmclog" : "/var/local/kmc/KMCLog.sh",' -i "/usr/share/app/kpp_sys_cmds.json"
	fi
fi