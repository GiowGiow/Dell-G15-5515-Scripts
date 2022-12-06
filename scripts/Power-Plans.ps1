. ".\Common-Functions.ps1"

$PowerPlans = New-Object PSObject -Property @{
    # Add a custom powerplan here if you want
    # The reason is: if you have a already good powerplan that you want to use that covers
    # both on AC and on DC, you dont need to change plans AT ALL
    TurboBoostDisabled  = "a2b00b5d-6ed8-4ad5-9d4c-18ad222e3d4c"
    PowerSaver          = "a1841308-3541-4fab-bc81-f71556f20b4a"
    Balanced            = "381b4222-f694-41f0-9685-ff5bb260df2e"
    HighPerformance     = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    UltimatePerformance = "e9a42b02-d5df-448d-aa00-03f14749eb61"
}

# I made the custom plan above with turbo boost disabled on battery based on this post:
# https://www.reddit.com/r/AcerNitro/comments/rfwjah/how_i_achieved_12_hours_battery_lifeguide/
# You can get a list of the power plan guids using powercfg /list

# I also tweaked it with QuickCPU.
# Basically on AC -> Runs on Balanced mode.
# On DC -> Runs on a tweaked battery saver mode with Turbo Boost Disabled

# PerfBoostMode enum to change PowerPlan Settings
$PerfBoostModes = New-Object PSObject -Property @{
    Disabled            = 0
    Enabled             = 1
    Aggressive          = 2
    Efficient           = 3
    EfficientAggressive = 4
}

function Disable-Turbo-Boost {
    # Sets a custom plan if it exists
    if (Assert-PowerPlan-Exists $PowerPlans.TurboBoostDisabled) {
        Powercfg.exe -SETACTIVE $PowerPlans.TurboBoostDisabled
    }
    # Set default power saver plan and disable turbo boost
    else {
        Powercfg.exe -setacvalueindex $PowerPlans.PowerSaver sub_processor PERFBOOSTMODE $PerfBoostModes.Disabled
        Powercfg.exe -SETACTIVE $PowerPlans.PowerSaver
    }
}

function Enable-Turbo-Boost {
    if (Assert-PowerPlan-Exists $PowerPlans.TurboBoostDisabled) {
        Powercfg.exe -SETACTIVE $PowerPlans.TurboBoostDisabled
    } else {
        Powercfg.exe -SETACTIVE $PowerPlans.Balanced
        # It may have been disabled if the default power saver plan was used, so we better set to aggressive again
        Powercfg.exe -setacvalueindex $PowerPlans.PowerSaver sub_processor PERFBOOSTMODE $PerfBoostModes.Aggressive
    }
}
