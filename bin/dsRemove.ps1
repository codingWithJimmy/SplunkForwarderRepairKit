### Configure file paths for the system
$LOCAL = {$(Test-Path "$SPLUNKHOME\etc\system\local\deploymentclient.conf")}
$DEPLOYED = {$(Test-Path "$SPLUNKHOME\etc\apps\*\*\deploymentclient.conf")}
$RESTART_CHECK = "$SPLUNKHOME\etc\restartds.txt"

### Filter to attach timestamps where necessary
filter timestamp {"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') ${env:COMPUTERNAME}: $_"}

### Check to see if there is a deploymentclient.conf file under $SPLUNK_HOME\etc\apps and bail out if there isn't
if ($DEPLOYED -eq "False") {
    Write-output "No deploymentclient.conf detected in \$SPLUNK_HOME\etc\apps. Bailing out so the fowarder doesn't get orphaned." | timestamp
} elseif ($LOCAL -eq "True") {
    ### Remove the local "deploymentclient.conf" and flag
    Write-output "Removed deploymentclient.conf from local system." | timestamp
    Remove-Item -Path "$LOCAL"
    Out-File -FilePath "$RESTART_CHECK"
} else { 
    Write-output "No deploymentclient.conf correction necessary." | timestamp
}