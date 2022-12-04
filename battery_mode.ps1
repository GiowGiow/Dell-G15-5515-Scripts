$DefaultPowerPlans = New-Object PSObject -Property @{
    # https://www.reddit.com/r/AcerNitro/comments/rfwjah/how_i_achieved_12_hours_battery_lifeguide/
    TurboBoostDisabled  = 'a2b00b5d-6ed8-4ad5-9d4c-18ad222e3d4c' # [Custom Plan] Turbo boost disabled
    PowerSaver          = "a1841308-3541-4fab-bc81-f71556f20b4a"
    Balanced            = "381b4222-f694-41f0-9685-ff5bb260df2e"
    HighPerformance     = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    UltimatePerformance = "e9a42b02-d5df-448d-aa00-03f14749eb61"
}

$DisplayHzOnBattery = 90
$DisplayHzDefault = 165
$LaptopDisplayNumber = 0
$BatterySaverThreshold = 100

# Start Logging
$LogFile = "log.txt"
Start-Transcript -path $LogFile -append

# Load Functions
. ".\common_functions.ps1"

$action = $args[0]

If ($action -eq 'start') {
    # Change the power plan
    Powercfg.exe -SETACTIVE $DefaultPowerPlans.TurboBoostDisabled
    Set-Laptop-Display-Hz -LaptopDisplayNumber $LaptopDisplayNumber -DisplayFrequency $DisplayHzOnBattery
    Start-Battery-Saver -BatteryThreshold $BatterySaverThreshold
    Set-Software-Battery-Mode "Battery"
    "Display is now running on $DisplayHzOnBattery" | Show-Notification -ToastTitle 'Battery Mode'
}
elseif ($action -eq 'stop') {
    # Set powersettings to balanced setting, activates turbo boost
    Powercfg.exe -SETACTIVE $DefaultPowerPlans.Balanced
    Set-Laptop-Display-Hz -LaptopDisplayNumber $LaptopDisplayNumber -DisplayFrequency $DisplayHzDefault
    Start-Battery-Saver -BatteryThreshold $BatterySaverThreshold
    Set-Software-Battery-Mode "AC"
    "Display is now running on $DisplayHzDefault" | Show-Notification -ToastTitle 'Balanced Mode'
}
else {
    Write-Host ("Not a valid action")
}

# Stop Logging
Stop-Transcript