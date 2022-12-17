## Configurations to pass btool checks without throwing errors

[script:<uniqueName>]
deploymentServerUri = [string]
* Correct URI that should be configured
* Default value is empty

deploymentClientApp = [string]
* App name that contains the correct deploymentclient.conf configuration
* Default value is empty

splunkUserName = [string]
* Value representing the username configured on the Universal Forwarder
* Default value is 'admin'

newPass = {auto|string}
* Value representing either a specified password to be configured or "auto"
* Default value is 'auto'

oldPass = [string]
* Value representing the old password configured on the Universal Forwarder
* Default is 'changeme'

printPass = {true|false}
* Determines if the new password that is generated will be sent to _internal
* Default value is 'false''. Change to 'true' to print password into _internal

include_default = {true|false}
* Used by btoolOutput.sh to determine if btool output will include 'system/default' as part of the output
* Default value is "false"

config_file = [string]
* Used by configCorrect.sh to define which config file to change
* Should only be the name of the file without the '.conf' suffix

stanza = [string]
* Used by configCorrect.sh to define which stanza to confiugure settings for

setting = [string]
* Used by configCorrect.sh to define which setting is being targeted for change

value = [string]
* Used by configCorrect.sh to define what the updated value is
* If "action" is set to "remove", "value" is ignored

action = {update|remove}
* Used by configCorrect.sh to define which setting is being targeted for change
* 'update' will update the existing value
* 'remove' will remove any local configuration of the value

destination_app = [string]
* Used by configCorrect.sh to define which app the setting will be configured in

[powershell:<uniqueName>]
deploymentServerUri = [string]
* Correct URI that should be configured with port

deploymentClientApp = [string]
* App name that contains the correct deploymentclient.conf configuration

splunkUserName = [string]
* Value representing the username configured on the Universal Forwarder
* Default value is 'admin'

newPass = {auto|string}
* Value representing either a specified password to be configured or "auto"
* Default value is 'auto'

oldPass = [string]
* Value representing the old password configured on the Universal Forwarder
* Default is 'changeme'

printPass = {true|false}
* Determines if the new password that is generated will be sent to _internal
* Default value is 'false''. Change to 'true' to print password into _internal

include_default = {true|false}
* Used by btoolOutput.sh to determine if btool output will include 'system/default' as part of the output
* Default value is "false"

config_file = [string]
* Used by configCorrect.ps1 to define which config file to change
* Should only be the name of the file without the '.conf' suffix

stanza = [string]
* Used by configCorrect.ps1 to define which stanza to confiugure settings for

setting = [string]
* Used by configCorrect.ps1 to define which setting is being targeted for change

value = [string]
* Used by configCorrect.ps1 to define what the updated value is
* If "action" is set to "remove", "value" is ignored

action = {update|remove}
* Used by configCorrect.ps1 to define which setting is being targeted for change
* 'update' will update the existing value
* 'remove' will remove any local configuration of the value

destination_app = [string]
* Used by configCorrect.ps1 to define which app the setting will be configured in