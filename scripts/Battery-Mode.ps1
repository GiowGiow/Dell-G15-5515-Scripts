# TODO: Get default values automatically
$DisplayHzOnBattery = 90
$DisplayHzDefault = 165
$LaptopDisplayNumber = 0
$BatterySaverThreshold = 100

# Start Logging
$LogFile = "log.txt"
Start-Transcript -path $LogFile -append

# Load Common Functions
. ".\Common-Functions.ps1"
. ".\Power-Plans.ps1"

$action = $args[0]

If ($action -eq 'start') {
    Disable-Turbo-Boost
    Set-Laptop-Display-Hz -LaptopDisplayNumber $LaptopDisplayNumber -DisplayFrequency $DisplayHzOnBattery
    Start-Battery-Saver -BatteryThreshold $BatterySaverThreshold
    Set-Software-Battery-Mode "Battery"
    "Display is now running on $DisplayHzOnBattery Hz`nTurbo Boost has been Disabled" | Show-Notification -ToastTitle 'Battery Mode'
}
elseif ($action -eq 'stop') {
    Enable-Turbo-Boost
    Set-Laptop-Display-Hz -LaptopDisplayNumber $LaptopDisplayNumber -DisplayFrequency $DisplayHzDefault
    Start-Battery-Saver -BatteryThreshold $BatterySaverThreshold
    Set-Software-Battery-Mode "AC"
    "Display is now running on $DisplayHzDefault Hz`nTurbo Boost has been Activated" | Show-Notification -ToastTitle 'Balanced Mode'
}
else {
    Write-Host ("Not a valid action")
}

# Stop Logging
Stop-Transcript