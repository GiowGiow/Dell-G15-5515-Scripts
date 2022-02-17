. ".\common_functions.ps1"

$action = $args[0]

If ($action -eq 'start') {
    Start-Program-If-Not-Running "C:\Program Files\AlienFX Tools" "alienfx-gui"
    Start-Program-If-Not-Running "C:\Program Files\AlienFX Tools" "alienfan-gui"
}
elseif ($action -eq 'stop') {
    # Kill Software on Battery
    Write-Host "Stopping and disabling alienfx-gui..."
    taskkill /IM "alienfx-gui.exe" /F /FI "STATUS ne UNKNOWN"

    # Stop Click Monitor DDC on battery
    Write-Host "Stopping and disabling alienfan-gui..."
    taskkill /IM "alienfan-gui.exe" /F /FI "STATUS ne UNKNOWN"
}
else {
    Write-Host ("Not a valid action")
}