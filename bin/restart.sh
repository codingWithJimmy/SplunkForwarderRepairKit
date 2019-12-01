#!/bin/bash
### Configure the path to the restart_check.txt file on the system
RESTARTINPUT="$SPLUNK_HOME/etc/restartinput.txt"
RESTARTSERVER="$SPLUNK_HOME/etc/restartserver.txt"
RESTARTDS="$SPLUNK_HOME/etc/restartds.txt"
RESTARTGUID="$SPLUNK_HOME/etc/restartguid.txt"
RESTARTDATETIME="$SPLUNK_HOME/etc/restartdatetime.txt"

### If any files exist, restart forwarder
if [ -f $RESTARTINPUT ] | [ -f $RESTARTSERVER ] | [ -f $RESTARTDS ] | [ -f $RESTARTGUID ] | [ -f $RESTARTDATETIME ]; then
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: One or more settings has been changed."
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: Restarting forwarder."
	if [ -f $RESTARTINPUT ]; then
		rm $RESTARTINPUT
	fi
	if [ -f $RESTARTSERVER ]; then
		rm $RESTARTSERVER
	fi
	if [ -f $RESTARTDS ]; then
		rm $RESTARTDS
	fi
	if [ -f $RESTARTGUID ]; then
		rm $RESTARTGUID
	fi
	if [ -f $RESTARTDATETIME ]; then
		rm $RESTARTDATETIME
	fi
	sleep 5
	$SPLUNK_HOME/bin/splunk restart
else
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: No settings have been changed."
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: No restart required."
fi