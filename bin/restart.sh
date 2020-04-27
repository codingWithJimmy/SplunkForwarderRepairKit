#!/bin/bash
### Configure the path to the restart_check.txt file on the system
RESTARTINPUT="$SPLUNK_HOME/etc/restartinput.txt"
RESTARTSERVER="$SPLUNK_HOME/etc/restartserver.txt"
RESTARTDS="$SPLUNK_HOME/etc/restartds.txt"
RESTARTGUID="$SPLUNK_HOME/etc/restartguid.txt"
RESTARTDATETIME="$SPLUNK_HOME/etc/restartdatetime.txt"

### If any files exist, restart forwarder
if [ -f "$RESTARTINPUT" ] || [ -f "$RESTARTSERVER" ] || [ -f "$RESTARTDS" ] || [ -f "$RESTARTGUID" ] || [ -f "$RESTARTDATETIME" ]; then
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: One or more settings has been changed."
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: Restarting forwarder."
	if [ -f "$RESTARTINPUT" ]; then
		rm -f "$RESTARTINPUT"
	fi
	if [ -f "$RESTARTSERVER" ]; then
		rm -f "$RESTARTSERVER"
	fi
	if [ -f "$RESTARTDS" ]; then
		rm -f "$RESTARTDS"
	fi
	if [ -f "$RESTARTGUID" ]; then
		rm -f "$RESTARTGUID"
	fi
	if [ -f "$RESTARTDATETIME" ]; then
		rm -f "$RESTARTDATETIME"
	fi
	rm -f $SPLUNK_HOME/etc/apps/SplunkForwarderRepairKit/DeleteMeToRestart
else
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: No settings have been changed."
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: No restart required."
fi
