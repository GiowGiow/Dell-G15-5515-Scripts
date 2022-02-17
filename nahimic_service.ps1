# Load Functions
. ".\common_functions.ps1"

$action = $args[0]

If ($action  -eq 'start')  {
    Write-Host "Starting Nahimic Tasks..."
    Enable-ScheduledTask -TaskName "NahimicSvc64Run"
    Enable-ScheduledTask -TaskName "NahimicSvc32Run"
    Enable-ScheduledTask -TaskName "NahimicTask32"
    Enable-ScheduledTask -TaskName "NahimicTask64"  

    Write-Host "Starting Nahimic Service..."
    $svc_name = "NahimicService"
    Set-Svc -action "start" -svc_name $svc_name
}
elseif ($action  -eq 'stop') {
    # Stopping Related Tasks
    Write-Host "Stopping Nahimic Tasks..."
    Disable-ScheduledTask -TaskName "NahimicSvc64Run"
    Disable-ScheduledTask -TaskName "NahimicSvc32Run"
    Disable-ScheduledTask -TaskName "NahimicTask32"
    Disable-ScheduledTask -TaskName "NahimicTask64"  

    # Nahimic Service
    Write-Host "Stopping Nahimic Service..."
    $svc_name = "NahimicService"
    Set-Svc -action "stop" -svc_name $svc_name
}
else {
    Write-Host ("Not a valid action")
}

Write-Host "Done!"