# TODO: Get default values automatically
$DisplayHzOnBattery = 90
$DisplayHzDefault = 165
$LaptopDisplayNumber = 0
$BatterySaverThreshold = 100

# Start Logging
$LogFile = "log.txt"
Start-Transcript -path $LogFile -append

# Load Common Functions
. "$PSScriptRoot\Common-Functions.ps1"
. "$PSScriptRoot\Power-Plans.ps1"
. "$PSScriptRoot\Dell-G15-Scripts.ps1"

$action = $args[0]

If ($action -eq 'start') {
    Change-TDP $Ryzen5800hTDPs.TDP15
    Set-Laptop-Display-Hz -LaptopDisplayNumber $LaptopDisplayNumber -DisplayFrequency $DisplayHzOnBattery
    Start-Battery-Saver -BatteryThreshold $BatterySaverThreshold
    Set-Software-Battery-Mode "Battery"
    "Display is now running on $DisplayHzOnBattery Hz`nTurbo Boost has been Disabled`nTDP is now 15W" | Show-Notification -ToastTitle 'Battery Mode'
}
elseif ($action -eq 'stop') {
    Change-TDP $Ryzen5800hTDPs.TDP45_85C
    Set-Laptop-Display-Hz -LaptopDisplayNumber $LaptopDisplayNumber -DisplayFrequency $DisplayHzDefault
    Set-Software-Battery-Mode "AC"
    "Display is now running on $DisplayHzDefault Hz`nTurbo Boost has been Activated`nTDP is now 45W" | Show-Notification -ToastTitle 'Balanced Mode'
}
else {
    Write-Host ("Not a valid action")
}

# Stop Logging
Stop-Transcript