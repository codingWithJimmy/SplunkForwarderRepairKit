#!/bin/bash
### Look for a deploymentclient.conf file in the apps directory and define the path to the restartds.txt file
DEPLOYED_APP=$(find $SPLUNK_HOME/etc/apps -type f -name deploymentclient.conf | wc -l)
LOCAL=$(find $SPLUNK_HOME/etc/system/local -type f -name deploymentclient.conf | wc -l)
RESTART_CHECK=$SPLUNK_HOME/etc/restartds.txt

### Check variables and take action accordingly
if [ $DEPLOYED_APP = "0" ]; then
        echo $(date -R) $HOSTNAME: No deploymentclient.conf detected in \$SPLUNK_HOME/etc/apps. Bailing out so the fowarder doesn\'t get orphaned.
        exit
elif [ $LOCAL = "1" ]; then
		# Remove the deploymentclient.conf from $SPLUNK_HOME/etc/system/local
		rm -f $SPLUNK_HOME/etc/system/local/deploymentclient.conf > /dev/null 2>&1
		echo $(date -R) $HOSTNAME: Removed deploymentclient.conf from local system.
		touch $RESTART_CHECK
else
		echo $(date -R) $HOSTNAME: No deploymentclient.conf correction necessary.
fi