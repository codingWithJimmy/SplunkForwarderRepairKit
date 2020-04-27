#!/bin/bash
### Look for a deploymentclient.conf file in the apps directory and define the path to the restartds.txt file
DEPLOYED_APP=$(find $SPLUNK_HOME/etc/apps -type f -name deploymentclient.conf | wc -l)
LOCAL=$(find $SPLUNK_HOME/etc/system/local -type f -name deploymentclient.conf | wc -l)
RESTART_CHECK=$SPLUNK_HOME/etc/restartds.txt

### Check variables and take action accordingly
## If there is no deployed app with a deployment client, bail out
if [ $DEPLOYED_APP = "0" ]; then
        echo $(date -R) $HOSTNAME: No deploymentclient.conf detected in $SPLUNK_HOME/etc/apps. Bailing out so the fowarder doesn\'t get orphaned.
        exit 1
      ## If more than one deploymentclient.conf file is deployed, bail out
      elif [ $DEPLOYED_APP > "1" ]; then
        echo $(date -R) $HOSTNAME: Multiple deploymentclient.conf detected in $SPLUNK_HOME/etc/apps. Check all deployed apps to ensure you\'re only using one.
        exit 1
      ## If there's 1 local config and 1 deployed config, remove the local one and set the checkpoint file
      elif [ $LOCAL = "1" ] & [ $DEPLOYED_APP = "1" ]; then
        # Remove the deploymentclient.conf from $SPLUNK_HOME/etc/system/local
        rm -f $SPLUNK_HOME/etc/system/local/deploymentclient.conf > /dev/null 2>&1
        echo $(date -R) $HOSTNAME: Removed deploymentclient.conf from local system.
        touch $RESTART_CHECK
      else
        echo $(date -R) $HOSTNAME: No deploymentclient.conf correction necessary.
fi
