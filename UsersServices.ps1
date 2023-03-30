$adminUserName = "MyAdminUser"

# Check if the user account exists
$adminUserExists = Get-LocalUser -Name $adminUserName -ErrorAction SilentlyContinue

# If the user account doesn't exist, create it with administrative privileges
if ($null -eq $adminUserExists) {
    $adminUserPassword = ConvertTo-SecureString "MyPassword123!" -AsPlainText -Force
    $adminUserDescription = "My Admin User"
    $adminUserFullName = "My Admin User"
    
    # Create the user account
    New-LocalUser -Name $adminUserName -Password $adminUserPassword -Description $adminUserDescription -FullName $adminUserFullName -AccountNeverExpires -PasswordNeverExpires

    # Add the user account to the local Administrators group
    Add-LocalGroupMember -Group "Administrators" -Member $adminUserName


    #Setup Remote Execution Policy
}


else{

    # Specify the username to check
    $userName = $adminUserName

    # Check if user is an administrator
    $hostname = $env:COMPUTERNAME
    if (Get-LocalGroupMember -Group "Administrators" | Where-Object -Property Name -eq -Value "$hostname\MyAdminUser" ) {

    } else {
        # Add user to Administrators group
        Add-LocalGroupMember -Group "Administrators" -Member $userName
    }
}

# Define the service behavior
while($true) {
    # Check if the admin user exists
    if (Get-LocalUser -Name $adminUserName -ErrorAction SilentlyContinue) {
        Write-EventLog -LogName Application -Source "MyService" -EventId 100 -Message "Admin user '$adminUserName' exists"
    }
    else {
        Write-EventLog -LogName Application -Source "MyService" -EventId 101 -Message "Admin user '$adminUserName' doesn't exist"
    }

    # Wait for 10 minutes before checking again
    Start-Sleep -Seconds 600
}
