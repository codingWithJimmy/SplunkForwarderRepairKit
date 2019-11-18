@echo off

REM Define checkpoint varaible
SET CHECKPOINT=%SPLUNK_HOME%\etc\ds_changed

REM Look for the checkpoint file and decide to exit or continue
IF EXIST "%CHECKPOINT%" (
	goto NOCHANGE
) ELSE (
	goto CHANGE
)

REM Remove "deploymentclient.conf" from $SPLUNK_HOME\etc\system\local
:CHANGE
IF NOT EXIST "%CHECKPOINT%" ( 
del /q "%SPLUNK_HOME%\etc\system\local\deploymentclient.conf"
) ELSE (
	goto FAILED
)

REM Create the checkpoint file and log success
:SUCCESS
echo %date% %time% %HOST%: Deploymentclient.conf removed from local system. > "%CHECKPOINT%"
echo %date% %time% %HOST%: Deploymentclient.conf removed from local system.
exit

REM Log that the deploymentclient.conf was already removed and exit
:NOCHANGE
echo %date% %time% %HOST%: Deploymentclient.conf removed from local system. > "%CHECKPOINT%"
echo %date% %time% %HOST%: Deploymentclient.conf already removed from local system.
exit
