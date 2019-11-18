### Configure file paths for the system
$INSTANCE_CHECK = {$(Test-Path "$SPLUNKHOME\etc\instance.cfg.*")}
$RESTART_CHECK = "$SPLUNKHOME\etc\restartguid.txt"

### Filter to attach timestamps where necessary
filter timestamp {"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') ${env:COMPUTERNAME}: $_"}

### Check to see if the GUID has already been replaced on this host previously by this script
if ($INSTANCE_CHECK -eq "True") {
    Write-output "This Splunk instance has already had the GUID regenerated." | timestamp
} else {
    ### Rename "instance.cfg" and set the restart flag in the checkpoint file
    Write-output "Backing up instance.cfg." | timestamp
    Copy-Item -Path "$INSTANCE" -Destination "$INSTANCE\instance_$(Get-Date -Format 'MMddyyyy').bak"
    Remove-Item -Path "$INSTANCE"
    Out-File -FilePath "$RESTART_CHECK"
}