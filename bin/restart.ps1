### Configure path to restart_check.txt
$inputPath = "$SPLUNKHOME\etc\restartinput.txt"
$serverPath = "$SPLUNKHOME\etc\restartserver.txt"
$dsPath = "$SPLUNKHOME\etc\restartds.txt"
$guidPath = "$SPLUNKHOME\etc\restartguid.txt"
$dateTimePath = "$SPLUNKHOME\etc\restartdatetime.txt"
$restartInput = $(Test-Path "$SPLUNKHOME\etc\restartinput.txt" -PathType Leaf)
$restartServer = $(Test-Path "$SPLUNKHOME\etc\restartserver.txt" -PathType Leaf)
$restartDS = $(Test-Path "$SPLUNKHOME\etc\restartds.txt" -PathType Leaf)
$restartGUID = $(Test-Path "$SPLUNKHOME\etc\restartguid.txt" -PathType Leaf)
$restartDateTime = $(Test-Path "$SPLUNKHOME\etc\restartdatetime.txt" -PathType Leaf)

### Filter to attach timestamps where necessary
filter timestamp {"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff zzz') ${env:COMPUTERNAME}: $_"}

if ($restartInput -eq "True" -OR $restartServer -eq "True" -OR $restartDS -eq "True" -OR $restartGUID -eq "True" -OR $restartDateTime -eq "True") {
	Write-output "One or more settings has been changed." | timestamp
	Write-output "Restarting forwarder." | timestamp
	if ($restartInput -eq "True") {
		Remove-Item -path "$inputPath"
	}
	if ($restartServer -eq "True") {
		Remove-Item -path "$serverPath"
	}
	if ($restartDS -eq "True") {
		Remove-Item -path "$dsPath"
	}
	if ($restartGUID -eq "True") {
		Remove-Item -path "$guidPath"
	}
	if ($restartDateTime -eq "True") {
		Remove-Item -path "$dateTimePath"
	}
	Remove-Item -path "$PSScriptRoot\DeleteMeToRestart"
} else {
	Write-output "No settings have been changed." | timestamp
	Write-output "No restart required." | timestamp
}
