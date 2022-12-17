### Grab variables from inputs.conf
$BTOOL_FILE = $args[0]
$BTOOL_INPUT = & $SPLUNKHOME\bin\splunk.exe cmd btool inputs list powershell://btoolOutput_$BTOOL_FILE --debug
$INCLUDE_DEFAULT_LINE = ($BTOOL_INPUT | findstr include_default)
$INCLUDE_DEFAULT = ("$INCLUDE_DEFAULT_LINE" -replace [regex]::Escape("$SPLUNKHOME\etc\app\"),"").Split(" ")[3]

### Filter to attach timestamps where necessary
filter timestamp {"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff zzz') ${env:COMPUTERNAME}: $_"}

### Capture btool output taking into account whether "system\default" is included
if ($INCLUDE_DEFAULT -eq "0" -OR $INCLUDE_DEFAULT -eq "false") {
  $BTOOL_OUTPUT = & $SPLUNKHOME\bin\splunk.exe cmd btool $BTOOL_FILE list  --debug | findstr -v "system\default" 
}
else {
  $BTOOL_OUTPUT = & $SPLUNKHOME\bin\splunk.exe cmd btool $BTOOL_FILE list  --debug 
}

### Print btool output
Write-output "btool output for ${BTOOL_FILE}.conf" | timestamp 
Write-output "============================================================================"
Write-output $BTOOL_OUTPUT
