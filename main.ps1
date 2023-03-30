$scriptBlock = {
    $timer = New-Object System.Timers.Timer
    $timer.Interval = 1800000 # 30 minutes
    $timer.AutoReset = $true
    $timer.Enabled = $true
    $timer.add_Elapsed({

        $winrmService = Get-Service -Name "WinRM"
        if ($winrmService.Status -ne "Stopped") {
            Stop-Service -Name $winrmService.Name
        }
        Set-Service -Name $winrmService.Name -StartupType Disabled




##########################################################################################################################

        # Create inbound and outbound firewall rules to block ICMP traffic if they don't already exist
        $inboundRule = Get-NetFirewallRule -DisplayName "Block ICMP Inbound" -ErrorAction SilentlyContinue
        if (!$inboundRule) {
            New-NetFirewallRule -DisplayName "Block ICMP Inbound" -Direction Inbound -Protocol ICMPv4 -IcmpType 0 -Action Block -ErrorAction SilentlyContinue
            Write-Host "Inbound firewall rule created to block ICMP traffic."
        }

        $outboundRule = Get-NetFirewallRule -DisplayName "Block ICMP Outbound" -ErrorAction SilentlyContinue
        if (!$outboundRule) {
            New-NetFirewallRule -DisplayName "Block ICMP Outbound" -Direction Outbound -Protocol ICMPv4 -IcmpType 0 -Action Block -ErrorAction SilentlyContinue
            Write-Host "Outbound firewall rule created to block ICMP traffic."
        }


##########################################################################################################################
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
            Set-ExecutionPolicy RemoteSigned -Force -Scope LocalMachine
        }
    })
}

Start-Job -ScriptBlock $scriptBlock
