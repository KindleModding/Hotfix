if [ -f "/app/kpp_app_cmds.json" ] ; then
	if ! grep -q "logThis.sh" "/app/kpp_app_cmds.json" ; then
		logmsg "I" "install_log_kpp" "" "Patching in the dispatch command for kpp"
        # KPP (React, new UI) (app)
        sed -e '/^{/a\' -e '    ";log" : "/usr/bin/logThis.sh",' -i "/app/kpp_app_cmds.json"
	fi

	if ! grep -q "KMCLog.sh" "/app/kpp_app_cmds.json" ; then
		logmsg "I" "install_log_kpp" "" "Patching in the KMC log command for kpp"
        sed -e '/^{/a\' -e '    ";kmclog" : "/var/local/kmc/KMCLog.sh",' -i "/app/kpp_app_cmds.json"
	fi
fi