### Capture current values for forwarder and configure file path variables for the system
$existingDateTime = "$SPLUNKHOME\etc\datetime.xml"
$referenceDateTime = "$SPLUNKHOME\apps\SplunkForwarderRepairKit\datetime.xml"
$restartDateTimeCheck = "$SPLUNKHOME\etc\restartdatetime.txt"

### Filter to attach timestamps where necessary
filter timestamp {"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') ${env:COMPUTERNAME}: $_"}

### Check flags and take appropriate actions for host name
if(Compare-Object -ReferenceObject $(Get-Content $existingDateTime) -DifferenceObject $(Get-Content $referenceDateTime)) {
    Write-output "The datetime.xml file needs to be updated. Updating..." | timestamp
    Copy-Item -Path "$existingDateTime" -Destination "$existingDateTime_$(Get-Date -Format 'MMddyyyy').bak"
    Copy-Item -Path "$referenceDateTime" -Destination "$existingDateTime"
    Out-File -FilePath "$restartDateTimeCheck"
} else {
    Write-output "The datetime.xml is the updated version. No correction necessary..."  | timestamp
}
