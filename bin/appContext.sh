#!/bin/bash
## Grab the current app context
SCRIPT_PATH=$(realpath $0)
APP_PATH=$(dirname ${SCRIPT_PATH})
SCRIPT_NAME=$(echo ${SCRIPT_PATH} | sed "s|${APP_PATH}/||")
APP_NAME=$(echo ${SCRIPT_PATH} | sed "s|${SPLUNK_HOME}/etc/apps||" | sed "s|/${SCRIPT_NAME}||")

## Capture the deploymentServerUri from the inputs stanza
if [ "${SCRIPT_NAME}" = "dsRemove.sh" ]; then
  CORRECT_DS=$(${SPLUNK_HOME}/bin/splunk btool --app=${APP_NAME} inputs list script://./bin/${SCRIPT_NAME} | grep deploymentServerUri | sed "s/deploymentServerUri = //")
  CORRECT_APP=$(${SPLUNK_HOME}/bin/splunk btool --app=${APP_NAME} inputs list script://./bin/${SCRIPT_NAME} | grep deploymentClientApp | sed "s/deploymentClientApp = //")
fi

## Capture the configuration details for changing the local password
if [ "${SCRIPT_NAME}" = "pwchange.sh" ]; then
  SPLUNK_USER=$(${SPLUNK_HOME}/bin/splunk btool --app=${APP_NAME} inputs list script://./bin/${SCRIPT_NAME} | grep newPass | sed "s/splunkUserName = //")
  NEWPASS=$(${SPLUNK_HOME}/bin/splunk btool --app=${APP_NAME} inputs list script://./bin/${SCRIPT_NAME} | grep newPass | sed "s/newPass = //")
  OLDPASS=$(${SPLUNK_HOME}/bin/splunk btool --app=${APP_NAME} inputs list script://./bin/${SCRIPT_NAME} | grep oldPass | sed "s/oldPass = //")
  PRINT_PASS=$(${SPLUNK_HOME}/bin/splunk btool --app=${APP_NAME} inputs list script://./bin/${SCRIPT_NAME} | grep printPass | sed "s/printPass = //")
fi

## Capture the configuration details for btool outputs
if [ "${SCRIPT_NAME}" = "btoolOutput.sh" ]; then
  BTOOL_INPUT=$(${SPLUNK_HOME}/bin/splunk btool --app=${APP_NAME} inputs list "script://./bin/btoolOutput.sh $1" --debug | grep include_default)
  INCLUDE_DEFAULT=$(echo ${BTOOL_INPUT} | awk '{print $4}')
fi
