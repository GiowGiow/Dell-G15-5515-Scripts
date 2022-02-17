# Load Functions
. ".\common_functions.ps1"

$action = $args[0]

If ($action -eq 'start') {
    # Nvidia Broadcast Service
    # This tasks runs when you logon and it starts Broadcast UI minimized
    # I dont want to activate it because I dont want it to run every startup
    # Enable-ScheduledTask -TaskName "NvBroadcast_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"  

    # You need this service to access the camera, mic and so on
    Write-Host "Starting Nvidia Broadcast Service..."
    $svc_name = "NvBroadcast.ContainerLocalSystem"

    Set-Svc -action "start" -svc_name $svc_name

    # & "C:\Program Files\NVIDIA Corporation\NVIDIA Broadcast\NVIDIA Broadcast UI.exe"
}
elseif ($action -eq 'stop') {
    # Nvidia Broadcast Service
    # Disabling related tasks
    ## This tasks runs when you logon and it starts Broadcast UI minimized
    Write-Host "Disabling NVBroadcast related tasks"
    Disable-ScheduledTask -TaskName "NvBroadcast_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"  

    taskkill /IM "NVIDIA Broadcast UI.exe" /F /FI "STATUS ne UNKNOWN"
    taskkill /IM "NVIDIA Broadcast.exe" /F /FI "STATUS ne UNKNOWN"

    ## You need this service to access the camera, mic and so on
    Write-Host "Stopping and disabling Nvidia Broadcast Service..."
    $svc_name = "NvBroadcast.ContainerLocalSystem"
    Set-Svc -action "stop" -svc_name $svc_name   
}
else {
    Write-Host ("Not a valid action")
}

Write-Host "Done!"