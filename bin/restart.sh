#!/bin/bash
### Source the appContext script to pull proper app context
. $(dirname $0)/appContext.sh

### Configure the path to the restart_check.txt file on the system
RESTARTINPUT="${SPLUNK_HOME}/etc/restartinput.txt"
RESTARTSERVER="${SPLUNK_HOME}/etc/restartserver.txt"
RESTARTDS="${SPLUNK_HOME}/etc/restartds.txt"
RESTARTGUID="${SPLUNK_HOME}/etc/restartguid.txt"
RESTARTCONFIGCORRECT="${SPLUNK_HOME}/etc/restartconfigcorrect.txt"

### If any files exist, restart forwarder
if [ -f "${RESTARTINPUT}" ] || [ -f "${RESTARTSERVER}" ] || [ -f "${RESTARTDS}" ] || [ -f "${RESTARTGUID}" ] || [ -f "${RESTARTCONFIGCORRECT}" ]; then
	echo "$(date -R) ${HOSTNAME}: One or more settings has been changed."
	echo "$(date -R) ${HOSTNAME}: Restarting forwarder."
	if [ -f "${RESTARTINPUT}" ]; then
		rm -f "${RESTARTINPUT}"
	fi
	if [ -f "${RESTARTSERVER}" ]; then
		rm -f "${RESTARTSERVER}"
	fi
	if [ -f "${RESTARTDS}" ]; then
		rm -f "${RESTARTDS}"
	fi
	if [ -f "${RESTARTGUID}" ]; then
		rm -f "${RESTARTGUID}"
	fi
	if [ -f "${RESTARTCONFIGCORRECT}" ]; then
		rm -f "${RESTARTCONFIGCORRECT}"
	fi
	rm -f "${APP_PATH}/bin/DeleteMeToRestart"
else
	echo "$(date -R) ${HOSTNAME}: No settings have been changed."
	echo "$(date -R) ${HOSTNAME}: No restart required."
fi
