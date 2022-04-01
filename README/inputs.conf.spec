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
