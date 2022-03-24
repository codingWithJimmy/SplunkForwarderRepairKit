### Capture current values for forwarder and configure file path variables for the system
$SPLUNK_LOCAL = "$SPLUNKHOME\etc\system\local"
$currentHost = Select-String $SPLUNK_LOCAL\inputs.conf -pattern "host = ([^$]+)" | Foreach-Object {$_.Matches} | Foreach-Object {$_.Groups[1].Value}
$currentServer = Select-String $SPLUNK_LOCAL\server.conf -pattern "serverName = ([^$]+)" | Foreach-Object {$_.Matches} | Foreach-Object {$_.Groups[1].Value}
$restartInputCheck = "$SPLUNKHOME\etc\restartinput.txt"
$restartServerCheck = "$SPLUNKHOME\etc\restartserver.txt"

### Filter to attach timestamps where necessary
filter timestamp {"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff zzz') ${env:COMPUTERNAME}: $_"}

### Compare values to actual host value and flag accordingly
if (-not ($currentHost -eq $env:COMPUTERNAME)){
    $correctHost="1"
} else {
    $correctHost="0"
}

if (-not ($currentServer -eq $env:COMPUTERNAME)){
    $correctServer="1"
} else {
    $correctServer="0"
}

### Check flags and take appropriate actions for host name
if ($correctHost -eq "1") {
    Write-output "Currently configured host name: $currentHost. Reconfiguring inputs.conf..." | timestamp
    Copy-Item -Path "$SPLUNK_LOCAL\inputs.conf" -Destination "$SPLUNK_LOCAL\inputs_$(Get-Date -Format 'MMddyyyy').bak"
    (Get-Content -path $SPLUNK_LOCAL\inputs.conf -Raw) -replace $currentHost,$env:COMPUTERNAME | Set-Content $SPLUNK_LOCAL\inputs.conf
    Out-File -FilePath "$restartInputCheck"
} else {
    Write-output "Currently configured host name: $currentHost. No correction necessary..."  | timestamp
}

### Check flags and take appropriate actions for server name
if ($correctServer -eq "1") {
    Write-output "Currently configured server name: $currentServer. Reconfiguring server.conf..." | timestamp
    Copy-Item -Path "$SPLUNK_LOCAL\server.conf" -Destination "$SPLUNK_LOCAL\server_$(Get-Date -Format 'MMddyyyy').bak"
    (Get-Content -path $SPLUNK_LOCAL\server.conf -Raw) -replace $currentServer,$env:COMPUTERNAME | Set-Content $SPLUNK_LOCAL\server.conf
    Out-File -FilePath "$restartServerCheck"
} else {
    Write-output "Currently configured server name: $currentServer. No correction necessary..." | timestamp
}
