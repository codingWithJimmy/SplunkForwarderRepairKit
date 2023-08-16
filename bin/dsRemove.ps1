### Grab variables from inputs.conf
$BTOOL_INPUT = & $SPLUNKHOME\bin\splunk.exe cmd btool inputs list powershell://dsRemove --debug
$CORRECT_DS_LINE = ($BTOOL_INPUT | findstr deploymentServerUri)
$CORRECT_DS_APP_LINE = ($BTOOL_INPUT | findstr deploymentClientApp)
$CORRECT_DS = ("$CORRECT_DS_LINE" -replace [regex]::Escape("$SPLUNKHOME\etc\apps\"), "").Split(" ")[3]
$CORRECT_DS_APP = ("$CORRECT_DS_APP_LINE" -replace [regex]::Escape("$SPLUNKHOME\etc\apps\"), "").Split(" ")[3]

if (!$CORRECT_DS) {
  Write-output "deploymentServerUri not configured in inputs.conf" | timestamp
  exit
}

if (!$CORRECT_DS_APP) {
  Write-output "deploymentClientApp not configured in inputs.conf" | timestamp
  exit
}

### Configure file paths for the system
$LOCAL = $((Get-ChildItem -Path "$SPLUNKHOME\etc\system\local" -Include deploymentclient.conf -File -Recurse).Count)
$DEPLOYED = $((Get-ChildItem -Path "$SPLUNKHOME\etc\apps" -Include deploymentclient.conf -File -Recurse).Count)
$LIST_APPS = $(Get-ChildItem -Path "$SPLUNKHOME\etc\apps" -Include deploymentclient.conf -File -Recurse)
$BAD_APPS = @(($LIST_APPS -replace "(default|local)\\deploymentclient.conf", "").where{ $_ -notmatch [regex]::Escape("$CORRECT_DS_APP") })
$RESTART_CHECK = "$SPLUNKHOME\etc\restartds.txt"

### Filter to attach timestamps where necessary
filter timestamp { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff zzz') ${env:COMPUTERNAME}: $_" }

## Capture the current configuration that Splunk is using from btool
$BTOOL = & $SPLUNKHOME\bin\splunk.exe cmd btool deploymentclient list --debug | FINDSTR 'targetUri'
$CURRENT_DS = ($BTOOL -replace [regex]::Escape("$SPLUNKHOME"), "").Split(" ")[3]
$CURRENT_APP_PATH = "$SPLUNKHOME" + ($BTOOL -replace [regex]::Escape("$SPLUNKHOME"), "" -replace "\\(default|local)\\deploymentclient.conf", "").Split(" ")[0]
$CURRENT_APP_NAME = ($CURRENT_APP_PATH -replace [regex]::Escape("$SPLUNKHOME\etc\apps\"), "")

### Check to see if there is a deploymentclient.conf file under $SPLUNKHOME\etc\apps and bail out if there isn't
if ($DEPLOYED -eq "0") {
  Write-output "No deploymentclient.conf detected in $SPLUNKHOME\etc\apps. Bailing out so the fowarder doesn't get orphaned." | timestamp
  Write-output "Deploy $CORRECT_APP to this server to correct this issue." | timestamp
}
elseif ($DEPLOYED -gt "1") {
  Write-output "Multiple deploymentclient.conf detected in $SPLUNKHOME\etc\apps." | timestamp
  Write-output "Removing bad app(s) to ensure there is no contention with $CORRECT_DS_APP" | timestamp
  foreach ($item in $BAD_APPS) {
    Remove-Item -Path "$item" -Force -Recurse -Confirm
    Write-output "Removed app: $item" | timestamp
  }
  Out-File -FilePath "$RESTART_CHECK"
}
elseif ($LOCAL -eq "1" -AND $DEPLOYED -eq "1") {
  Write-output "Removed deploymentclient.conf from local system." | timestamp
  Remove-Item -Path "$LOCAL" -Force -Confirm
  Out-File -FilePath "$RESTART_CHECK"
}
else {
  Write-output "No deploymentclient.conf correction necessary." | timestamp
}
