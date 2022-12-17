### Capture current values for forwarder and configure file path variables for the system
$BTOOL_INPUT = & $SPLUNKHOME\bin\splunk.exe cmd btool inputs list powershell://configCorrect --debug
$RESTART_CONFIG_CORRECT_CHECK = "$SPLUNKHOME\etc\restartconfigcorrect.txt"

### Filter to attach timestamps where necessary
filter timestamp {"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff zzz') ${env:COMPUTERNAME}: $_"}

## Capture values of configurations to change
$SFRK_APP = ($BTOOL_INPUT -replace [regex]::Escape("$SPLUNKHOME\etc\apps\"),"" -replace "\\(default|local)\\inputs.conf","").Split(" ")[0]
$CORRECT_CONFIG_FILE_LINE = ($BTOOL_INPUT | findstr config_file)
$CORRECT_STANZA_LINE = ($BTOOL_INPUT | findstr stanza)
$CORRECT_SETTING_LINE = ($BTOOL_INPUT | findstr setting)
$CORRECT_VALUE_LINE = ($BTOOL_INPUT | findstr value)
$CORRECT_ACTION_LINE = ($BTOOL_INPUT | findstr action)

## Turn settings from inputs into usable variables
$CORRECT_CONFIG_FILE = ("$CORRECT_CONFIG_FILE_LINE" -replace [regex]::Escape("$SPLUNKHOME\etc\apps\"),"").Split(" ")[3]
$CORRECT_STANZA = ("$CORRECT_STANZA_LINE" -replace [regex]::Escape("$SPLUNKHOME\etc\apps\"),"").Split(" ")[3]
$CORRECT_SETTING = ("$CORRECT_SETTING_LINE" -replace [regex]::Escape("$SPLUNKHOME\etc\apps\"),"").Split(" ")[3]
$CORRECT_VALUE = ("$CORRECT_VALUE_LINE" -replace [regex]::Escape("$SPLUNKHOME\etc\apps\"),"").Split(" ")[3]
$CORRECT_ACTION = ("$CORRECT_ACTION_LINE" -replace [regex]::Escape("$SPLUNKHOME\etc\apps\"),"").Split(" ")[3]

## Capture the current setting and its location
$CURRENT_SETTING = & $SPLUNKHOME\bin\splunk.exe cmd btool $CORRECT_CONFIG_FILE list $CORRECT_STANZA --debug | findstr $CORRECT_SETTING
$CURRENT_SETTING_LOCATION = ("$CURRENT_SETTING" -replace [regex]::Escape("$SPLUNKHOME\etc\apps\"),"").Split(" ")[3]

### Check flags and take appropriate actions for server name
if ($correctServer -eq "1") {
    Write-output "Currently configured server name: $currentServer. Reconfiguring server.conf..." | timestamp
    Copy-Item -Path "$SPLUNK_LOCAL\server.conf" -Destination "$SPLUNK_LOCAL\server_$(Get-Date -Format 'MMddyyyy').bak"
    (Get-Content -path $SPLUNK_LOCAL\server.conf -Raw) -replace $currentServer,$env:COMPUTERNAME | Set-Content $SPLUNK_LOCAL\server.conf
    Out-File -FilePath "$RESTART_CONFIG_CORRECT_CHECK"
} else {
    Write-output "Currently configured server name: $currentServer. No correction necessary..." | timestamp
}
