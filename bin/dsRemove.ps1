### Configure file paths for the system
$LOCAL = {$((Get-ChildItem -Path "$SPLUNKHOME\etc\system\local" -Include deploymentclient.conf -File -Recurse).Count)}
$DEPLOYED = {$((Get-ChildItem -Path "$SPLUNKHOME\etc\apps" -Include deploymentclient.conf -File -Recurse).Count)}
$RESTART_CHECK = "$SPLUNKHOME\etc\restartds.txt"

### Filter to attach timestamps where necessary
filter timestamp {"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') ${env:COMPUTERNAME}: $_"}

### Check to see if there is a deploymentclient.conf file under $SPLUNKHOME\etc\apps and bail out if there isn't
if ($DEPLOYED -eq "0") {
    Write-output "No deploymentclient.conf detected in $SPLUNKHOME\etc\apps. Bailing out so the fowarder doesn't get orphaned." | timestamp
} elseif ($DEPLOYED -gt "1") {
    Write-output "Multiple deploymentclient.conf detected in $SPLUNKHOME\etc\apps. Check all deployed apps to ensure you\'re only using one." | timestamp
} elseif ($LOCAL -eq "1" -AND $DEPLOYED -eq "1") {
    ### Remove the local "deploymentclient.conf" and flag
    Write-output "Removed deploymentclient.conf from local system." | timestamp
    Remove-Item -Path "$LOCAL"
    Out-File -FilePath "$RESTART_CHECK"
} else {
    Write-output "No deploymentclient.conf correction necessary." | timestamp
}
