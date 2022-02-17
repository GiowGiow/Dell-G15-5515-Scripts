# Name                                   Value
# -----                                  -----
# 381b4222-f694-41f0-9685-ff5bb260df2e   SCHEME_BALANCED  # --> Balanced
# 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c   SCHEME_MIN       # --> High performance
# 381b4222-f694-41f0-9685-ff5bb260df2e   SCHEME_MAX       # --> Power saver

# Load Functions
. ".\common_functions.ps1"

$action = $args[0]

# List power consumption profile schemes
$powerConstants = @{}
PowerCfg.exe -ALIASES | Where-Object { $_ -match 'SCHEME_' } | ForEach-Object {
    $guid,$alias = ($_ -split '\s+', 2).Trim()
    $powerConstants[$alias] = $guid 
}

# Get a list of power schemes and check the one that is active
$powerSchemes = PowerCfg.exe -LIST | Where-Object { $_ -match '^GUID' } | ForEach-Object {
    $guid = $_ -replace '.*GUID:\s*([-a-f0-9]+).*', '$1'
    [PsCustomObject]@{
        Name     = $_.Trim("* ") -replace '.*\(([^)]+)\)$', '$1'          # LOCALIZED !
        Alias    = $powerConstants[$guid]
        Guid     = $guid
        IsActive = $_ -match '\*$'
    }
}

# Set a variable for each of the power schemes (just to make it more readable)
$highPerformance = $powerConstants['SCHEME_MIN']
$battery = $powerConstants['SCHEME_MAX']
$balanced = $powerConstants['SCHEME_BALANCED']

If ($action -eq 'start') {
    # Change the power plan based on what power plan is active right now
    # Set battery saver power plan, disables turbo boost as well
    # with a lot of tweaks from: 
    # https://www.reddit.com/r/AcerNitro/comments/rfwjah/how_i_achieved_12_hours_battery_lifeguide/
    Write-Host "Power Plan is now on battery mode"
    Powercfg.exe -SETACTIVE $battery
    
    # Set monitor 0 (laptop screen) to 60hz
    # from: https://tools.taubenkorb.at/change-screen-resolution/
    Write-Host "Monitor is now working on 90Hz"
    & ".\ChangeScreenResolution.exe" "/d=0" "/f=90" >$null 2>&1
    
    # Set battery saver mode (windows 11) to run always
    Write-Host "Energy Saver is now running always"
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 100
    
    # I don't know why windows keeps bugging with the brightness
    Write-Host "Setting brightness"
    (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1,40)

    & ".\software_on_battery" "stop"
}
elseif ($action -eq 'stop') {
    # Set powersettings to balanced setting, activates turbo boost
    Write-Host "Power Plan is now on balanced mode!"
    Powercfg.exe -SETACTIVE $balanced

    # Change monitor 0 back to 165hz
    Write-Host "Monitor is now working on 165Hz"
    & ".\ChangeScreenResolution.exe" "/d=0" "/f=165" >$null 2>&1

    # Setting powersaver to run at 50% battery
    Write-Host "Energy Saver is now running always"
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD 100

    # I don't know why windows keeps bugging with the brightness
    Write-Host "Setting brightness"
    (Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods).WmiSetBrightness(1,80)

    & ".\software_on_battery" "start"

    Write-Host "Power Plan Settings are now on balanced!"    
}
else {
    Write-Host ("Not a valid action")
}