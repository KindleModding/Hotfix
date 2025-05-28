if [ -f "/usr/share/app/kpp_sys_cmds.json" ] ; then
	if ! grep -q "logThis.sh" "/usr/share/app/kpp_sys_cmds.json" ; then
		logmsg "I" "install_log_kpp" "" "Patching in the dispatch command for kpp"
        # KPP (React, new UI) (sys)
        sed -e '/^{/a\' -e '    ";log" : "/usr/bin/logThis.sh", ";condmode" : "/usr/sbin/reboot",' -i "/usr/share/app/kpp_sys_cmds.json"
	fi
fi