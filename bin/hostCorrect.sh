#!/bin/bash
### Capture the existing host and serverName values and define path to restart checkpoint file
INPUTS_FILE="$SPLUNK_HOME/etc/system/local/inputs.conf"
SERVER_FILE="$SPLUNK_HOME/etc/system/local/server.conf"
RESTART_INPUT_CHECK="$SPLUNK_HOME/etc/restartinput.txt"
RESTART_SERVER_CHECK="$SPLUNK_HOME/etc/restartserver.txt"

### Check for the existence of the inputs file and create if it doesn't exist
if [ -f "$INPUTS_FILE" ]; then
	CURRENT_HOST=$(cat "$INPUTS_FILE" | grep "host =" | awk '{printf $3}')
else
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: Inputs file is missing from local config. Creating it now..."
	touch "$INPUTS_FILE"
	echo "[default]
	host = IntentionallyWrong" > "$INPUTS_FILE"
	CURRENT_HOST=$(cat "$INPUTS_FILE" | grep "host =" | awk '{printf $3}')
fi

### Check for the existence of a serverName value and insert one if one isn't configured
CURRENT_SERVER=$(cat "$SERVER_FILE" | grep "serverName =" | awk '{printf $3}')
if [ -z "CURRENT_SERVER" ]; then
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: There is no serverName value configured. Inserting one..."
	echo "
	[general]
	serverName = IntentionallyWrong" >> "$SERVER_FILE"
	CURRENT_SERVER=$(cat "$SERVER_FILE" | grep "serverName =" | awk '{printf $3}')
fi

### Check the current values of the configured files and correct if necessary
if [ "$CURRENT_HOST" = "$HOSTNAME" ]; then
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: Currently configured host name: $CURRENT_HOST. No correction necessary..."
else
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: Currently configured host name: $CURRENT_HOST. Reconfiguring inputs.conf..."
	cp "$INPUTS_FILE" "$INPUTS_FILE".$(date +"%m%d%Y")
	sed -i "s/$CURRENT_HOST/$HOSTNAME/" "$INPUTS_FILE"
	touch "$RESTART_INPUT_CHECK"
fi
if [ "$CURRENT_SERVER" = "$HOSTNAME" ]; then
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: Currently configured server name: $CURRENT_SERVER. No correction necessary..."
else
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: Currently configured server name: $CURRENT_SERVER. Reconfiguring inputs.conf..."
	cp "$SERVER_FILE" "$SERVER_FILE".$(date +"%m%d%Y")
	sed -i "s/$CURRENT_SERVER/$HOSTNAME/" "$SERVER_FILE"
	touch "$RESTART_SERVER_CHECK"
fi
