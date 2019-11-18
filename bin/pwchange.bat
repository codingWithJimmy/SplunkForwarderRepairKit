@echo off
REM Define the original and new passwords here. To use automatic password generation, change NEWPASS to 'auto'
SET OLDPASS=changeme
SET NEWPASS=auto

REM Settings for automatic password generation. Not used if NEWPASS is not set to 'auto'
Setlocal EnableDelayedExpansion
SET _RNDLength=16
SET _Alphanumeric=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789
SET _Str=%_Alphanumeric%987654321

REM Other variables relating to the checkpoint file and the path to test login and hostname for logging
SET CHECKPOINT=%SPLUNK_HOME%\etc\pwd_changed
SET LOGIN_COMMAND="%SPLUNK_HOME%\bin\splunk.exe" login -auth admin:%OLDPASS%
FOR /F "usebackq" %%i IN (`hostname`) DO SET HOST=%%i

REM Look for the checkpoint file and decide to error or continue
IF EXIST "%CHECKPOINT%" (
	goto NOCHANGE
) ELSE IF "%NEWPASS%"=="auto" (
	goto AUTOCHANGE
) ELSE (
	goto CHANGE
)

REM Attempt to login to local Splunk account. If successful, generate a new password and change it.
:AUTOCHANGE
FOR /F "tokens=2 usebackq" %%C in (`%LOGIN_COMMAND%`) DO SET LOGIN=%%C  
:_LenLoop
IF NOT "%LOGIN%"=="Failed" (
IF NOT "%_Str:~18%"=="" SET _Str=%_Str:~9%& SET /A _Len+=9& GOTO :_LenLoop
SET _tmp=%_Str:~9,1%
SET /A _Len=_Len+_tmp
Set _count=0
SET NEWPASS=
:_loop
Set /a _count+=1
SET _RND=%Random%
Set /A _RND=_RND%%%_Len%
SET NEWPASS=!NEWPASS!!_Alphanumeric:~%_RND%,1!
If !_count! lss %_RNDLength% goto _loop
"%SPLUNK_HOME%\bin\splunk.exe" edit user admin -password "%NEWPASS%" >NUL
	goto AUTOSUCCESS
) ELSE (
	goto FAILED
)

REM Attempt to login to local Splunk account. If successful, generate a new password and change it.
:CHANGE
FOR /F "tokens=2 usebackq" %%C in (`%LOGIN_COMMAND%`) DO SET LOGIN=%%C 
IF NOT "%LOGIN%"=="Failed" (
"%SPLUNK_HOME%\bin\splunk.exe" edit user admin -password "%NEWPASS%" >NUL
	goto SUCCESS
) ELSE (
	goto FAILED
)

REM Create the checkpoint file and log success. This will print the password in the log message passed back to Splunk.
:AUTOSUCCESS
echo %date% %time% %HOST%: Splunk account password successfully changed. > "%CHECKPOINT%"
echo %date% %time% %HOST%: Splunk account password successfully changed. Automatic password: %NEWPASS%
exit

REM Create the checkpoint file and log success.
:SUCCESS
echo %date% %time% %HOST%: Splunk account password successfully changed. > "%CHECKPOINT%"
echo %date% %time% %HOST%: Splunk account password successfully changed.
exit

REM Login failure
:FAILED
echo %date% %time% %HOST%: Splunk account login failed. Old password is not correct for this host.
exit

REM Log that the checkpoint file exists
:NOCHANGE
echo %date% %time% %HOST%: Splunk account password was already changed.
exit
