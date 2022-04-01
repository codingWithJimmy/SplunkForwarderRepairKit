### Grab variables from inputs.conf
$BTOOL_INPUT = & $SPLUNKHOME\bin\splunk.exe cmd btool inputs list powershell://pw_change
$SPLUNK_USER_NAME = ($BTOOL_INPUT | findstr splunkUserName).Split(" ")[2]
$NEW_PASS_SETTING = ($BTOOL_INPUT | findstr newPass).Split(" ")[2]
$OLD_PASS_SETTING = ($BTOOL_INPUT | findstr oldPass).Split(" ")[2]
$PRINT_PASS_SETTING = ($BTOOL_INPUT | findstr printPass).Split(" ")[2]

### Configure file paths for the checkpoint
$PW_CHANGED = "$SPLUNKHOME\etc\pw_changed"
$PW_CHECK = (Test-Path -Path "$PW_CHANGED")

### Function for generation of a random password
Function GeneratePassword
{
    $MinimumPasswordLength = 12
    $MaximumPasswordLength = 16
    $PasswordLength = Get-Random -InputObject ($MinimumPasswordLength..$MaximumPasswordLength)
    $AllowedPasswordCharacters = [char[]]'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?@#£$%^&'
    $Regex = "(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)"

    do {
            $Password = ([string]($AllowedPasswordCharacters |
            Get-Random -Count $PasswordLength) -replace ' ')
       }    until ($Password -cmatch $Regex)

    $Password

}

### Filter to attach timestamps where necessary
filter timestamp {"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff zzz') ${env:COMPUTERNAME}: $_"}

### Check to see if there is a pw_changed file under $SPLUNKHOME\etc and bail out if there is
if ( $PW_CHECK -eq "True" )
{
    Write-output "Splunk account password was already changed." | timestamp
    Exit
}

### Capture the current password hash to check for a successful change
$PASS_HASH_GET = Get-ChildItem $SPLUNKHOME\etc\passwd | select-string $SPLUNK_USER_NAME
$OLD_HASH = ($PASS_HASH_GET -Split {$_ -eq ":"}) | findstr "\$"

### Set random password if newPass is "auto"
if ( $NEW_PASS_SETTING -eq "auto" )
{
    Write-output "Configuring random password..." | timestamp
    $NEWPASS = (GeneratePassword)
    $OLDPASS = $OLD_PASS_SETTING
    if ( $PRINT_PASS_SETTING -eq "true" -or $PRINT_PASS_SETTING -eq "1" )
    {
        Write-output "New password: ${NEWPASS}" | timestamp
    }
    & ${SPLUNKHOME}\bin\splunk edit user ${SPLUNK_USER_NAME} -password ${NEWPASS} -auth ${SPLUNK_USER_NAME}:${OLDPASS} 2>$null
    $NEW_HASH_GET = Get-ChildItem $SPLUNKHOME\etc\passwd | select-string $SPLUNK_USER_NAME
    $NEW_HASH = ($NEW_HASH_GET -Split {$_ -eq ":"}) | findstr "\$"
    if ( $NEW_HASH -ne $OLD_HASH ) {
        Write-output "Password changed." | timestamp
        Out-File -FilePath "$PW_CHANGED"
    } else {
        Write-output "Password change failed. Creating user-seed.conf." | timestamp
        Rename-Item -Path $SPLUNKHOME\etc\passwd -NewName $SPLUNKHOME\etc\passwd.bak
        "[user_info]" | Out-File -FilePath $SPLUNKHOME\etc\system\local\user-seed.conf
        "USERNAME = ${SPLUNK_USER_NAME}" | Out-File -FilePath $SPLUNKHOME\etc\system\local\user-seed.conf -Append
        "PASSWORD = ${NEWPASS}" | Out-File -FilePath $SPLUNKHOME\etc\system\local\user-seed.conf -Append
        Out-File -FilePath "$PW_CHANGED"
    }
}

### Set configured password if newPass is not "auto"
if ( $NEW_PASS_SETTING -ne "auto" )
{
    Write-output "Configuring specific password..." | timestamp
    $NEWPASS = $NEW_PASS_SETTING
    $OLDPASS = $OLD_PASS_SETTING
    if ( $PRINT_PASS_SETTING -eq "true" -or $PRINT_PASS_SETTING -eq "1" )
    {
        Write-output "New password: '$NEWPASS'" | timestamp
    }
    & ${SPLUNKHOME}\bin\splunk edit user ${SPLUNK_USER_NAME} -password ${NEWPASS} -auth ${SPLUNK_USER_NAME}:${OLDPASS} | Out-Null
    $NEW_HASH_GET = Get-ChildItem $SPLUNKHOME\etc\passwd | select-string $SPLUNK_USER_NAME
    $NEW_HASH = $NEW_HASH_GET -Split {$_ -eq ":"} | findstr "\$"

    if ( $NEW_HASH -ne $OLD_HASH )
    {
        Write-output "Password changed." | timestamp
        Out-File -FilePath "$PW_CHANGED"
    } else {
        Write-output "Password change failed. Creating user-seed.conf." | timestamp
        Rename-Item -Path $SPLUNKHOME\etc\passwd -NewName $SPLUNKHOME\etc\passwd.bak
        "[user_info]" | Out-File -FilePath "$SPLUNKHOME\etc\system\local\user-seed.conf"
        "USERNAME = $SPLUNK_USER_NAME" | Out-File -FilePath "$SPLUNKHOME\etc\system\local\user-seed.conf" -Append
        "PASSWORD = $NEWPASS" | Out-File -FilePath "$SPLUNKHOME\etc\system\local\user-seed.conf" -Append
        Out-File -FilePath "$PW_CHANGED"
    }
}
