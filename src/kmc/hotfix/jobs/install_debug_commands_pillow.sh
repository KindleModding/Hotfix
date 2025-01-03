if [ -f "/usr/share/webkit-1.0/pillow/debug_cmds.json" ] ; then
	if ! grep -q "logThis.sh" "/usr/share/webkit-1.0/pillow/debug_cmds.json" ; then
		logmsg "I" "install_log_pillow" "" "Patching in the dispatch command for pillow"
        # Pillow (old UI)
        sed -e '/^{/a\' -e '    ";log" : "/usr/bin/logThis.sh",' -i "/usr/share/webkit-1.0/pillow/debug_cmds.json"
	fi
fi