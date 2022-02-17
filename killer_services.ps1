# Load Functions
. ".\common_functions.ps1"

$action = $args[0]

If ($action -eq 'start') {
    ## Killer Services
    Write-Host "Starting KAPSService, KNDBWM, Killer Network Service" 
    
    ### Killer Analytics Service
    ### Make sure this is always disabled, this spies on you
    $services = @("KAPSService", "KNDBWM", "Killer Network Service", "xTendUtilityService", "xTendSoftAPService")
    For ($service = 0; $service -lt $services.Length; $service++) {
        Write-Host "Starting" $services[$service]
        Set-Svc -action "start" -svc_name $services[$service]
    }
}
elseif ($action -eq 'stop') {
    Write-Host "Stopping Killer Analytics Service, KAPSService, KNDBWM, Killer Network Service, xTendUtilityService, xTendSoftAPService" 
    $services = @("Killer Analytics Service", "KAPSService", "KNDBWM", "Killer Network Service", "xTendUtilityService", "xTendSoftAPService")

    For ($service = 0; $service -lt $services.Length; $service++) {
        Write-Host "Stopping" $services[$service]
        Set-Svc -action "stop" -svc_name $services[$service]
    }
}
else {
    Write-Host ("Not a valid action")
}

Write-Host "Done!"