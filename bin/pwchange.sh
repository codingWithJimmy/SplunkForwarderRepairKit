#!/bin/bash
# Define the original and new passwords here. To have a password automatically generated, set NEWPASS to 'auto'
OLDPASS=changeme
NEWPASS=auto

# Look for the checkpoint file and error out if it exists
if [ -f $SPLUNK_HOME/etc/pwd_changed ]
then
        echo $(date -R) $HOSTNAME: Splunk account password was already changed.
        exit
fi

if [ "$NEWPASS" = "auto" ]
then
	NEWPASS=$(head -c 500 /dev/urandom | sha256sum | base64 | head -c 16 ; echo)
	NEWPASSAUTO=$(echo Automatic password: $NEWPASS)
fi

# Change the password
$SPLUNK_HOME/bin/splunk edit user admin -password $NEWPASS -auth admin:$OLDPASS > /dev/null 2>&1

# Check splunkd.log for any error messages relating to login during the script and determine whether the change was successful or not
CHANGED=$(tail -n 10 $SPLUNK_HOME/var/log/splunk/splunkd.log | grep pwchange | grep Login)
if [ -z "$CHANGED" ]
then
	echo $(date -R) $HOSTNAME: Splunk account password successfully changed. $NEWPASSAUTO
	echo $(date -R) $HOSTNAME: Splunk account password successfully changed. > $SPLUNK_HOME/etc/pwd_changed
else
	echo $(date -R) $HOSTNAME: Splunk account login failed. Old password is not correct for this host.
fi
