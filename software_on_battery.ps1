. ".\common_functions.ps1"

$action = $args[0]

If ($action -eq 'start') {
    Start-Program-If-Not-Running "C:\Program Files\Rainmeter" "Rainmeter"
    Start-Program-If-Not-Running "C:\Users\gioma\Documents\utilities\clickmonitorddc" "ClickMonitorDDC_7_2"
}
elseif ($action -eq 'stop') {
    # Kill Software on Battery
    Write-Host "Stopping and disabling Rainmeter..."
    taskkill /IM "Rainmeter.exe" /F /FI "STATUS ne UNKNOWN"

    # Stop Click Monitor DDC on battery
    Write-Host "Stopping and disabling ClickMonitorDDC..."
    taskkill /IM "ClickMonitorDDC_7_2.exe" /F /FI "STATUS ne UNKNOWN"
}
else {
    Write-Host ("Not a valid action")
}