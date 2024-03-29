# Splunk Forwarder Repair Kit
This kit was compiled based on common issues with Splunk deployments and managing idiosyncrasies that tend to naturally occur.

## Using the app
Given the use-cases listed below, you will likely have multiple copies of the app with different scripted inputs enabled for each case. In any case, the app should restart Splunk when it is installed as all of the inputs are designed to be run when the forwarder starts.

It should be noted that if multiple copies of the app are created, the inputs.conf would need to be adjusted to account for the change in path for Windows Powershell scripts.

Below is the default inputs file. This configuration is responsible for running the scripts each time the forwarder restarts except for the restart script. The restart script is on a cron for every 2 minutes and is designed to only trigger a restart under specific circumstances.

```
### Restart scripts
[script://./bin/restart.sh]
disabled = 1
index = _internal
sourcetype = restart:output
interval = */2 * * * *
source = restart_output

[powershell://restart]
disabled = 1
index = _internal
sourcetype = restart:output
schedule = */2 * * * *
source = restart_output
script = . "$SplunkHome\etc\apps\SplunkForwarderRepairKit\bin\restart.ps1"

### GUID regneration scripts
[script://./bin/regenGUID.sh]
disabled = 1
index = _internal
sourcetype = regen_guid:output
interval = -1
source = regen_guid_output

[powershell://regenGUID]
disabled = 1
index = _internal
sourcetype = regen_guid:output
source = regen_guid_output
script = . "$SplunkHome\etc\apps\SplunkForwarderRepairKit\bin\regenGUID.ps1"

### Host/Server correction scripts
[script://./bin/hostCorrect.sh]
disabled = 1
index = _internal
sourcetype = host_rename:output
interval = -1
source = host_rename_output

[powershell://hostCorrect]
disabled = 1
index = _internal
sourcetype = host_rename:output
source = host_rename_output
script = . "$SplunkHome\etc\apps\SplunkForwarderRepairKit\bin\hostCorrect.ps1"

### Local deploymentclient removal scripts
[script://./bin/dsRemove.sh]
disabled = 1
index = _internal
sourcetype = ds_remove:output
interval = -1
source = ds_remove_output
deploymentServerUri =
deploymentClientApp =

[powershell://dsRemove]
disabled = 1
index = _internal
sourcetype = ds_remove:output
source = ds_remove_output
script = . "$SplunkHome\etc\apps\SplunkForwarderRepairKit\bin\dsRemove.ps1"
deploymentServerUri =
deploymentClientApp =

### Admin password change scripts
[script://./bin/pwchange.sh]
disabled = 1
index = _internal
sourcetype = pw_change:output
interval = -1
source = pw_change_output
splunkUserName = admin
newPass = auto
oldPass = changeme
printPass = false

[powershell://pwchange]
disabled = 1
index = _internal
sourcetype = pw_change:output
interval = -1
source = pw_change_output
script = . "$SplunkHome\etc\apps\SplunkForwarderRepairKit\bin\pwchange.ps1"
splunkUserName = admin
newPass = auto
oldPass = changeme
printPass = false
```

## Use-Cases
1. Local deployment server configurations
2. Inputs and server host name configurations
3. Duplicate forwarder GUIDs
4. Changing the default password (Version <= 7.1.0)

###### Remove local deployment server configurations
Early in a deployment of Splunk, local configurations could be used while getting familiar with how Splunk works. These configurations may last for a while and cause issues down the road like if a new deployment server is stood up or an IP address changes.

This app contains scripts for Windows and Linux forwarders that will remove local configurations of "deploymentclient.conf" in favor of a configuration that has been deployed from the deployment server. This allows for that configuration to only be controlled via the deployment server from that point forward.

Once the proper app and deployment server configurations are deployed to the host(s) using the `deploymentServerUri` and `deploymentClientApp` configurations in inputs.conf, this app will remove all configurations that would prevent those configurations for working.

Windows - `dsRemove.ps1`\
\*Nix - `dsRemove.sh`

###### Correct inputs/server host name configurations
Many times we've come across an environment where hundreds of forwarders are reporting with the same name and forwarder GUID. This usually happens when an image template isn't properly maintained after a forwarder has been embedded in it.

This app contains scripts for Windows and Linux forwarders that will determine if correction is necessary in the local "inputs.conf" and "server.conf" and correct them. The scripts are designed to only change what is needed and leave the rest of the files unchanged.

Windows - `hostCorrect.ps1`\
\*Nix - `hostCorrect.sh`

###### Regenerate forwarder GUID
Another by-product of the previous use-case is forwarder GUIDs all being the same. While this doesn't affect how a forwarder performs its duties, unique GUIDs ensures if hosts have the same name they are still uniquely identifiable for troubleshooting purposes.

This app contains scripts for Windows and Linux forwarders that will move the existing "instance.cfg" to become a backup and restart the forwarder. Upon restarting, a new GUID will be generated.

Windows - `regenGUID.ps1`\
\*Nix - `regenGUID.sh`

###### Install updated datetime.xml file (REMOVED)
The scripts that performed this action have been retired. This method is also not the safest method to update this file and should not be used. It is preferable to simply upgrade Splunk versions (Splunk Enterprise or Splunk Universal Forwarder) that already has this fix in place.

https://docs.splunk.com/Documentation/Splunk/latest/ReleaseNotes/FixDatetimexml2020#Upgrade_Splunk_platform_instances_to_a_version_with_an_updated_version_of_datetime.xml

~~A notice was sent out in November of 2019 that stated there was an issue with the datetime.xml that would affect data ingested due to a misconfigured datetime.xml. The bug and fix can be read about here: https://docs.splunk.com/Documentation/Splunk/latest/ReleaseNotes/FixDatetimexml2020~~

~~This app contains scripts for Windows and Linux forwarders that will back up the existing "datetime.xml" to replace with the corrected version contained within the app.~~

~~**NOTE: This should only be used on Universal Forwarders. Please see the above documentation link for instructions for other Splunk instances.**~~

~~Windows - `dateTimeCorrect.ps1`\
\*Nix - `dateTimeCorrect.sh`~~

###### Update local user password on Splunk Forwarders (primary installations before 7.1.0)
Forwarders deployed before version 7.1.0 didn't require the admin password be changed upon installation. Starting at 7.1.0, the forwarders required either a user-seed file or manual input of the password during first-time run. While the REST API of the forwarder is not configured to allow POST requests until the password is changed on versions prior to 7.1.0, changing the password is still recommended.

The variables for the environment can be configured in inputs.conf when the app is deployed such as the Splunk username (default 'admin'), whether to automatically generate a random password or to set it explicitly (default 'auto'), the value of the old password (default 'changeme'), and whether or not to send the new password back in plain-text to Splunk (default 'false').

Windows - `pwchange.ps1`\
\*Nix - `pwchange.sh`

## Restarting the Forwarder
Because most of these use-cases require the forwarders be restarted, an additional script has been introduced that takes the outcome of each of the scripts used and determines if a restart is required. Each script is designed to create an empty file that the restart script uses to determine if a restart is necessary. If the restart script finds one of the files used to trigger a restart, it removes them as well as one other file. Removing the other file should trigger a restart from the deployment server when the app re-syncs for the now missing file.

Windows - `restart.ps1`\
\*Nix - `restart.sh`
