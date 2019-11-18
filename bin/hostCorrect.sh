#!/bin/bash
### Capture the existing host and serverName values and define path to restart checkpoint file
INPUTS_FILE=$SPLUNK_HOME/etc/system/local/inputs.conf
SERVER_FILE=$SPLUNK_HOME/etc/system/local/server.conf
CURRENT_HOST=$(cat $INPUTS_FILE | grep "host =" | awk '{printf $3}')
CURRENT_SERVER=$(cat $SERVER_FILE | grep "serverName =" | awk '{printf $3}')
RESTART_INPUT_CHECK="$SPLUNK_HOME/etc/restartinput.txt"
RESTART_SERVER_CHECK="$SPLUNK_HOME/etc/restartserver.txt"

### Compare those values and correct if necessary
if [ $CURRENT_HOST = $HOSTNAME ]; then
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: Currently configured host name: $CURRENT_HOST. No correction necessary..."
else
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: Currently configured host name: $CURRENT_HOST. Reconfiguring inputs.conf..."
	cp $INPUTS_FILE $INPUTS_FILE.$(date +"%m%d%Y")
	touch $RESTART_INPUT_CHECK
fi
if [ $CURRENT_SERVER = $HOSTNAME ]; then
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: Currently configured server name: $CURRENT_SERVER. No correction necessary..."
else
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: Currently configured server name: $CURRENT_SERVER. Reconfiguring inputs.conf..."
	cp $SERVER_FILE $SERVER_FILE.$(date +"%m%d%Y")
	touch $RESTART_SERVER_CHECK
fi