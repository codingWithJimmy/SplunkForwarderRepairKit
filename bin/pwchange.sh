#!/bin/bash
## Run appContext to capture details from inputs stanza
. $(dirname $0)/appContext.sh

# Look for the checkpoint file and error out if it exists
if [ -f $SPLUNK_HOME/etc/pwd_changed ]; then
  echo $(date -R) $HOSTNAME: Splunk account password was already changed.
  exit
fi

# Generate a random password if newPass is set to "auto" in inputs.conf
if [ "$NEWPASS" = "auto" ]; then
	NEWPASS=$(head -c 500 /dev/urandom | sha256sum | base64 | head -c 16 ; echo)
fi
if [ "$PRINT_PASS" = "1" ] || [ "$PRINT_PASS" = "true" ]; then
  echo "$(date -R) $HOSTNAME: New password: $NEWPASS"
fi

# Capture current user password hash
OLD_PASS_HASH=$(cat $SPLUNK_HOME/etc/passwd | grep $SPLUNK_USER | sed "s/:/ /g" | awk '{ print $2 }')

# Attempt to change the password with the provided password in inputs.conf
$SPLUNK_HOME/bin/splunk edit user $SPLUNK_USER -password $NEWPASS -auth $SPLUNK_USER:$OLDPASS > /dev/null 2>&1

# Capture the user password hash to see if it changed
NEW_PASS_HASH=$(cat $SPLUNK_HOME/etc/passwd | grep $SPLUNK_USER | sed "s/:/ /g" | awk '{ print $2 }')

# Compare the old user hash to the new user hash and generate a user-seed.file if they still match
if [ "$OLD_PASS_HASH" != "$NEW_PASS_HASH" ]; then
	echo "$(date -R) $HOSTNAME: Splunk account password successfully changed. $NEWPASSAUTO"
  touch $SPLUNK_HOME/etc/pwd_changed
else
	echo $(date -R) $HOSTNAME: Password change failed. Creating user-seed.conf.
  mv "$SPLUNK_HOME/etc/passwd" "$SPLUNK_HOME/etc/password.backup."
  cat <<<EOF "$SPLUNK_HOME/etc/system/local/user-seed.conf"
  [user-info]
  USERNAME = $SPLUNK_USER
  PASSWORD = $NEWPASS

  EOF
  touch $SPLUNK_HOME/etc/pwd_changed
  rm $APP_PATH/bin/DeleteMeToRestart
fi
