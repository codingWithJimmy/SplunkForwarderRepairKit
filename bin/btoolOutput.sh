#!/bin/bash

## Run appContext to capture details from inputs stanza
. $(dirname $0)/appContext.sh $1

### Capture btool output
BTOOL_OUTPUT=$(${SPLUNK_HOME}/bin/splunk btool $1 list --debug)

### Print btool output taking into account whether "system\default" is included
if [ "${INCLUDE_DEFAULT}" = "false" ] || [ "${INCLUDE_DEFAULT}" = "0" ]; then
  echo "$(date -R) ${HOSTNAME}: btool output for $1.conf"
  echo "============================================================================"
  echo "${BTOOL_OUTPUT}" | grep -v 'system/default'
elif [ "${INCLUDE_DEFAULT}" = "true" ] || [ "${INCLUDE_DEFAULT}" = "1" ]; then
  echo "$(date -R) ${HOSTNAME}: btool output for $1.conf"
  echo "============================================================================"
  echo "${BTOOL_OUTPUT}"
else
  echo "$(date -R) ${HOSTNAME}: \"include_default\" is not included in the input."
fi
