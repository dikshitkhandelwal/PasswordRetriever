# Define the service name and description
$serviceName = "MyWinRMScriptService"
$serviceDesc = "Windows service that runs a script to disable WinRM and block ICMP traffic"

# Define the path to the PowerShell executable and the script file
$exePath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$scriptPath = "C:\path\to\my\script.ps1"

# Create a new Windows service that runs the script
sc.exe create $serviceName binPath= "$exePath -ExecutionPolicy Bypass -File `"$scriptPath`"" DisplayName= "$serviceName" start= auto description= "$serviceDesc"
# Start the service
net start $serviceName


