#!/bin/bash
### Path to instance.cfg and restart_check.txt for the system
INSTANCE="$SPLUNK_HOME/etc/instance.cfg"
RESTART_CHECK="$SPLUNK_HOME/etc/restartguid.txt"

### Check if there is already a backup of the instance.cfg and take the appropriate action.
if [ -f "${INSTANCE}.*" ]; then
	echo "$(date -R) ${HOSTNAME}: Instance GUID has already been changed."
	CHECK="0"
else
	echo "$(date -R) ${HOSTNAME}: Backing up instance.cfg"
	mv "$INSTANCE" "${INSTANCE}.$(date +"%m%d%Y")"
	touch $RESTART_CHECK
fi
