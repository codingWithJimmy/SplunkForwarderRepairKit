### Configure file paths for the system
$INSTANCE_FILE = "$SPLUNKHOME\etc\instance.cfg"
$INSTANCE_CHECK = {$(Test-Path "$INSTANCE_FILE.*")}
$RESTART_CHECK = "$SPLUNKHOME\etc\restartguid.txt"

### Filter to attach timestamps where necessary
filter timestamp {"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff zzz') ${env:COMPUTERNAME}: $_"}

### Check to see if the GUID has already been replaced on this host previously by this script
if ($INSTANCE_CHECK -eq "True") {
    Write-output "This Splunk instance has already had the GUID regenerated." | timestamp
} else {
    ### Rename "instance.cfg" and set the restart flag in the checkpoint file
    Write-output "Backing up instance.cfg." | timestamp
    Copy-Item -Path "$INSTANCE_FILE" -Destination "$INSTANCE_FILE.$(Get-Date -Format 'MMddyyyy').bak"
    Remove-Item -Path "$INSTANCE_FILE"
    Out-File -FilePath "$RESTART_CHECK"
}
