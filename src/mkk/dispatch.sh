#!/bin/sh
#
# Kindle Oasis Dispatch
#
# $Id: dispatch.sh 16928 2020-03-08 18:29:45Z NiLuJe $
#
##

## NOTE: We always bridge this, even though it's no longer accessible on stock FW >= 5.12.2,
##       because the ;log debug command is gone. Emphasis on "stock", though ;).

## Check our args...
if [ "$#" -ne 1 ] ; then
	eips 1 0 "No arg passed. Select from mrpi or runme"
	return 0
fi

case "${1}" in
	# Launch MRPI!
	"mrpi" | "MRPI" | m* )
		if [ -f "/mnt/us/extensions/MRInstaller/bin/mrinstaller.sh" ] ; then
			if [ "$(id -u)" -ne 0 ] ; then
				if [ -x "/var/local/mkk/gandalf" ] ; then
					exec /var/local/mkk/su -s /bin/sh -c "/mnt/us/extensions/MRInstaller/bin/mrinstaller.sh launch_installer"
				else
					eips 1 0 "No wizard to help you out.              "
					# Run it anyway, who knows.
					exec /bin/sh "/mnt/us/extensions/MRInstaller/bin/mrinstaller.sh" launch_installer
				fi
			else
				exec /bin/sh "/mnt/us/extensions/MRInstaller/bin/mrinstaller.sh" launch_installer
			fi
		else
			eips 1 0 "MRPI is not installed.                  "
		fi
	;;
	# Launch user script!
	"custom" | "CUSTOM" | "runme" | "RUNME" | r* )
		if [ -f "/mnt/us/RUNME.sh" ] ; then
			if [ "$(id -u)" -ne 0 ] ; then
				if [ -x "/var/local/mkk/gandalf" ] ; then
					exec /var/local/mkk/su -s /bin/sh -c "/mnt/us/RUNME.sh"
				else
					eips 1 0 "No wizard to help you out.              "
					# Run it anyway, who knows.
					exec /bin/sh "/mnt/us/RUNME.sh"
				fi
			else
				exec /bin/sh "/mnt/us/RUNME.sh"
			fi
		else
			eips 1 0 "No user script found.                   "
		fi
	;;
	* )
		eips 1 0 "Wrong arg. Select from mrpi or runme    "
	;;
esac

return 0
