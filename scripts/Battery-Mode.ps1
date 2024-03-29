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

$Action = $args[0]

If (Test-Is-On-Battery) {
    if ($Action -eq "reapply") {
        Change-TDP $Ryzen5800hTDPs.TDP15
    } elseif ($Action -eq "apply") {
        Disable-Turbo-Boost
        Change-TDP $Ryzen5800hTDPs.TDP15
        Set-Laptop-Display-Hz -LaptopDisplayNumber $LaptopDisplayNumber -DisplayFrequency $DisplayHzOnBattery
        Start-Battery-Saver -BatteryThreshold $BatterySaverThreshold
        Set-Software-Battery-Mode "Battery"
        "Display is now running on $DisplayHzOnBattery Hz`nTurbo Boost has been Disabled`nTDP is now 15W" | Show-Notification -ToastTitle 'Battery Mode'
    }
}
else {
    if ($Action -eq "reapply") {
        Change-TDP $Ryzen5800hTDPs.TDP45_85C
    } elseif ($Action -eq "apply") {
        Enable-Turbo-Boost
        Change-TDP $Ryzen5800hTDPs.TDP45_85C
        Set-Laptop-Display-Hz -LaptopDisplayNumber $LaptopDisplayNumber -DisplayFrequency $DisplayHzDefault
        Set-Software-Battery-Mode "AC"
        "Display is now running on $DisplayHzDefault Hz`nTurbo Boost has been Activated`nTDP is now 45W" | Show-Notification -ToastTitle 'Balanced Mode'
    }
}

# Stop Logging
Stop-Transcript