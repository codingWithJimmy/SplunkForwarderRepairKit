#!/bin/bash
### Determine the difference in the reference datetime.xml in the app and the datetime.xml currently used by Splunk
EXISTING_DATETIME="$SPLUNK_HOME/etc/datetime.xml"
REFERENCE_DATETIME="$SPLUNK_HOME/etc/apps/SplunkForwarderRepairKit/datetime.xml"
DATETIME_DIFFERENCE=$(diff $REFERENCE_DATETIME $EXISTING_DATETIME | wc -l)
RESTART_DATETIME_CHECK="$SPLUNK_HOME/etc/restartdatetime.txt"

### Determine if a correction is necessary
if [ $DATETIME_DIFFERENCE = 0 ]; then
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: The datetime.xml is the updated version. No correction necessary..."
else
	echo "$(date +"%Y-%m-%d %H:%M:%S.%3N") ${HOSTNAME}: The datetime.xml file needs to be updated. Updating..."
	mv $EXISTING_DATETIME $EXISTING_DATETIME.$(date +"%m%d%Y")
	cp $REFERENCE_DATETIME $EXISTING_DATETIME
	touch $RESTART_DATETIME_CHECK
fi
