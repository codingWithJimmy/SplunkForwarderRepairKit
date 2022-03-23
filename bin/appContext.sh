#!/bin/bash
## Grab the current app context
SCRIPT_PATH=$(realpath $0)
APP_PATH=$(dirname ${SCRIPT_PATH})
SCRIPT_NAME=$(echo ${SCRIPT_PATH} | sed "s|${APP_PATH}/||")
APP_NAME=$(echo ${SCRIPT_PATH} | sed "s|${SPLUNK_HOME}/etc/apps" | sed "s|/${SCRIPT_NAME}||")

## Capture the deploymentServerUri from the inputs stanza
if [ "${SCRIPT_NAME}" = "dsRemove.sh" ]; then
  CORRECT_DS=$(${SPLUNK_HOME}/bin/splunk btool --app=$APP_NAME inputs list script://./bin/$SCRIPT_NAME | grep deploymentServerUri | sed "s/deploymentServerUri = //")
  CORRECT_APP=$(${SPLUNK_HOME}/bin/splunk btool --app=$APP_NAME inputs list script://./bin/$SCRIPT_NAME | grep deploymentClientApp | sed "s/deploymentClientApp = //")
fi
