if [ -f "/app/kpp_app_cmds.json" ] ; then
	if ! grep -q "logThis.sh" "/app/kpp_app_cmds.json" ; then
		logmsg "I" "install_log_kpp" "" "Patching in the dispatch command for kpp"
        # KPP (React, new UI) (app)
        sed -e '/^{/a\' -e '    ";log" : "/usr/bin/logThis.sh", ";condmode" : "/usr/sbin/reboot",' -i "/app/kpp_app_cmds.json"
	fi
fi