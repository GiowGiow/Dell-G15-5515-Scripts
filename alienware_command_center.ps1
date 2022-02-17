# Load Functions
. ".\common_functions.ps1"

$action = $args[0]

If ($action  -eq 'start')  {
    ## Alienware Command Center Service
    ### Kinda sucks because then you cant control keyboard lights
    $svc_name = "AWCCService"
    Set-Svc -action "start" -svc_name $svc_name
}
elseif ($action  -eq 'stop') {
    ## Alienware Command Center Service
    ### Kinda sucks because then you cant control keyboard lights
    ### So use this only when you really need that battery
    $svc_name = "AWCCService"
    Set-Svc -action "stop" -svc_name $svc_name

    Write-Host "Stop AWCC..."
    taskkill /IM "AWCC.exe" /F /FI "STATUS ne UNKNOWN"

    Write-Host "Stop AWCC.Service.exe..."
    taskkill /IM "AWCC.Background.Server.exe" /F /FI "STATUS ne UNKNOWN"

    Write-Host "Stop AWCC.Service.exe..."
    taskkill /IM "AWCC.Service.exe" /F /FI "STATUS ne UNKNOWN"
}
else {
    Write-Host ("Not a valid action")
}


