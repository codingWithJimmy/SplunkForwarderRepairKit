#!/bin/bash

## Run appContext to capture details from inputs stanza
. $(dirname $0)/appContext.sh

### Look for a deploymentclient.conf file in the apps directory and define the path to the restartds.txt file
CORRECT_APP_DEPLOYED=$(find $SPLUNK_HOME/etc/apps -type d -name ${CORRECT_APP} | wc -l)
DEPLOYED_APP=$(find $SPLUNK_HOME/etc/apps -type f -name deploymentclient.conf | wc -l)
LOCAL=$(find $SPLUNK_HOME/etc/system/local -type f -name deploymentclient.conf | wc -l)
RESTART_CHECK=$SPLUNK_HOME/etc/restartds.txt

## Capture the current deployment server URI from btool
BTOOL=$(${SPLUNK_HOME}/bin/splunk btool deploymentclient list --debug | grep targetUri)
CURRENT_DS=$(echo ${BTOOL} | awk '{print $4}')
CURRENT_APP_PATH=$(echo ${BTOOL} | awk '{print $1}' | sed "s/\/(default|local)\/deploymentclient.conf//"
CURRENT_APP_NAME=$(echo ${CURRENT_APP_PATH} | sed "s|${SPLUNK_HOME}\/etc\/apps\/||")

## If there is no deployed app with a deployment client, bail out
if [ $DEPLOYED_APP = "0" ]; then
  echo "$(date -R) $HOSTNAME: No deploymentclient.conf detected in $SPLUNK_HOME/etc/apps. Bailing out so the fowarder doesn\'t get orphaned."
  echo "$(date -R) $HOSTNAME: Deploy \"${CURRENT_APP_NAME}\" to this server to correct this issue."
  exit 1
fi

## If more than one deploymentclient.conf file is deployed, nuke the wrong app and set the checkpoint file
if [ $DEPLOYED_APP > "1" ]; then
  echo "$(date -R) $HOSTNAME: Multiple apps with deploymentclient.conf detected in $SPLUNK_HOME/etc/apps."
  echo "$(date -R) $HOSTNAME: Removing ${CURRENT_APP_NAME} to ensure there is no contention with ${CORRECT_APP}"
  rm -rf "${CURRENT_APP_PATH}"
  touch $RESTART_CHECK
fi

## If there's 1 local config, remove the local one and set the checkpoint file
if [ $LOCAL = "1" ]; then
  # Remove the deploymentclient.conf from $SPLUNK_HOME/etc/system/local
  rm -f $SPLUNK_HOME/etc/system/local/deploymentclient.conf > /dev/null 2>&1
  echo $(date -R) $HOSTNAME: Removed deploymentclient.conf from local system.
  touch $RESTART_CHECK
fi

## If the current deployment server is configured and the correct app is installed, bail out
if [ "${CURRENT_DS}" = "${CORRECT_DS}" ] && [ "${CURRENT_APP}" = "${CORRECT_APP}" ]; then
  echo $(date -R) $HOSTNAME: No deploymentclient.conf correction necessary.
fi
