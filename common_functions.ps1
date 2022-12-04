# Send a Windows Notification to show what status are we running now
# This function notifies when a profile has been set
# from here: https://den.dev/blog/powershell-windows-notification/
function Show-Notification {
    [cmdletbinding()]
    Param (
        [string]
        $ToastTitle,
        [string]
        [parameter(ValueFromPipeline)]
        $ToastText
    )

    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null
    $Template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)

    $RawXml = [xml] $Template.GetXml()
    ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "1" }).AppendChild($RawXml.CreateTextNode($ToastTitle)) > $null
    ($RawXml.toast.visual.binding.text | Where-Object { $_.id -eq "2" }).AppendChild($RawXml.CreateTextNode($ToastText)) > $null

    $SerializedXml = New-Object Windows.Data.Xml.Dom.XmlDocument
    $SerializedXml.LoadXml($RawXml.OuterXml)

    $Toast = [Windows.UI.Notifications.ToastNotification]::new($SerializedXml)
    $Toast.Tag = "Quick Options"
    $Toast.Group = "Quick Options"
    $Toast.ExpirationTime = [DateTimeOffset]::Now.AddMinutes(1)

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Quick Options")
    $Notifier.Show($Toast);
}

function Set-Service-State {
    param(
        [string]$SvcName, 
        [string]$State # start or stop
    )
    If ($State -eq "enable") {
        Get-Service $SvcName | Set-Service -StartupType Automatic -PassThru | Start-Service 
    }
    elseif ($State -eq "disable") {
        # It stops and DISABLES a service
        Get-Service $SvcName | Stop-Service -PassThru | Set-Service -StartupType Disabled
    }
    else {
        Write-Host ("Not a valid action")
    }
}

function Start-Program-If-Not-Running {
    Param (
        [string]
        $executablePath,
        [string]
        $programName
    )

    $isRunning = (Get-Process | Where-Object { $_.Name -eq $programName }).Count -gt 0
    if ($isRunning) {
        Write-Host "Already running..."
    }
    else {
        Write-Host "Starting $programName..."
        Start-Process -WindowStyle Minimized "$executablePath"
    }
}
function Set-Software-Battery-Mode {
    # Stop/Change behaviour of some softwares on battery
    param (
        [string] $State # Should be AC or Battery
    )
    $RainmeterPath = "C:\Program Files\Rainmeter\Rainmeter.exe"

    If ($State -eq "AC") {
        & $RainmeterPath !LoadLayout "Desktop Layout"
    }
    elseif ($State -eq "Battery") {
        & $RainmeterPath !LoadLayout "Laptop Layout"
    }
    else {
        Write-Host ("Not a valid action")
    }
}
function Start-Battery-Saver {
    # Set battery saver mode (windows 10/11) to start on battery at a certain battery threshold
    Param (
        [string] $BatteryThreshold
    )
    powercfg /setdcvalueindex SCHEME_CURRENT SUB_ENERGYSAVER ESBATTTHRESHOLD $BatteryThreshold 
}

function Set-Laptop-Display-Hz {
    # Set monitor to defined Hz using this binary
    # from: https://tools.taubenkorb.at/change-screen-resolution/
    Param (
        [string] $LaptopDisplayNumber,
        [string] $DisplayFrequency
    )
    & ".\ChangeScreenResolution.exe" "/d=$LaptopDisplayNumber" "/f=$DisplayFrequency" > $null 2>&1
}

function Set-Killer-Services-State {
    param (
        [string] $State
    )
    If ($State -eq "enable") {
        $Services = @("KAPSService", "KNDBWM", "Killer Network Service",
            "xTendUtilityService", "xTendSoftAPService")

        For ($Index = 0; $Index -lt $Services.Length; $Index++) {
            Set-Service-State -action "enable" -SvcName $Services[$Index]
        }
    }
    elseif ($State -eq "disable") {
        $Services = @("Killer Analytics Service", 
            "KAPSService", "KNDBWM", "Killer Network Service",
            "xTendUtilityService", "xTendSoftAPService")

        For ($Index = 0; $Index -lt $Services.Length; $Index++) {
            Set-Service-State -action "disable" -SvcName $Services[$Index]
        }
    }
    else {
        Write-Host ("Not a valid State")
    }
}


function Set-Nahimic-Services-State {
    param (
        [string] $State
    )
    If ($State -eq "enable") {
        # Nahimic Related Tasks
        Enable-ScheduledTask -TaskName "NahimicSvc64Run"
        Enable-ScheduledTask -TaskName "NahimicSvc32Run"
        Enable-ScheduledTask -TaskName "NahimicTask32"
        Enable-ScheduledTask -TaskName "NahimicTask64" 

        # Nahimic Service
        Set-Service-State -State $State -SvcName "NahimicService"
    }
    elseif ($State -eq "disable") {
        # Nahimic Related Tasks
        Disable-ScheduledTask -TaskName "NahimicSvc64Run"
        Disable-ScheduledTask -TaskName "NahimicSvc32Run"
        Disable-ScheduledTask -TaskName "NahimicTask32"
        Disable-ScheduledTask -TaskName "NahimicTask64"  

        # Nahimic Service
        Set-Service-State -State $State -SvcName "NahimicService"
    }
    else {
        Write-Host ("Not a valid State")
    }
}

function Set-AWCC-State {
    param (
        [string] $State
    )
    If ($State -eq "enable") {
        Set-Service-State -State $State -SvcName "AWCCService"
    }
    elseif ($State -eq "disable") {
        Set-Service-State -State $State -SvcName "AWCCService"
        taskkill /IM "AWCC.exe" /F /FI "STATUS ne UNKNOWN"
        taskkill /IM "AWCC.Background.Server.exe" /F /FI "STATUS ne UNKNOWN"
        taskkill /IM "AWCC.Service.exe" /F /FI "STATUS ne UNKNOWN"
    }
    else {
        Write-Host ("Not a valid State")
    }
}

function Set-NVIDIA-BroadCast-State {
    param (
        [string] $State
    )
    $NvidiaBroadcastExePath = "C:\Program Files\NVIDIA Corporation\NVIDIA Broadcast\NVIDIA Broadcast UI.exe"

    If ($State -eq "enable") {
        # You need this service to access the camera, mic and so on
        Set-Service-State -State $State -SvcName "NvBroadcast.ContainerLocalSystem"
        & $NvidiaBroadcastExePath
    }
    elseif ($State -eq "disable") {
        # This tasks runs when you logon and it starts Broadcast UI minimized
        Disable-ScheduledTask -TaskName "NvBroadcast_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"  
        taskkill /IM "NVIDIA Broadcast UI.exe" /F /FI "STATUS ne UNKNOWN"
        taskkill /IM "NVIDIA Broadcast.exe" /F /FI "STATUS ne UNKNOWN"
        Set-Service-State -State $State -SvcName "NvBroadcast.ContainerLocalSystem"
    }
    else {
        Write-Host ("Not a valid state")
    }
}

function Set-Alien-Tools-State {
    param (
        [string] $State
    )
    If ($State -eq "enable") {
        Start-Program-If-Not-Running "C:\Program Files\AlienFX Tools\alienfx-gui.exe" "alienfx-gui"
    }
    elseif ($State -eq "disable") {
        taskkill /IM "alienfx-gui.exe" /F /FI "STATUS ne UNKNOWN"
    }
    else {
        Write-Host ("Not a valid state")
    }
}

function Assert-Power-Plan-Battery-Mode {
    # List power consumption profile schemes
    $powerConstants = @{}
    PowerCfg.exe -ALIASES | Where-Object { $_ -match "SCHEME_" } | ForEach-Object {
        $guid, $alias = ($_ -split "\s+", 2).Trim()
        $powerConstants[$alias] = $guid 
    }

    # Get a list of power schemes and check the one that is active
    $powerSchemes = PowerCfg.exe -LIST | Where-Object { $_ -match "^GUID" } | ForEach-Object {
        $guid = $_ -replace ".*GUID:\s*([-a-f0-9]+).*", "$1"
        [PsCustomObject]@{
            Name     = $_.Trim("* ") -replace ".*\(([^)]+)\)$", "$1"          # LOCALIZED !
            Alias    = $powerConstants[$guid]
            Guid     = $guid
            IsActive = $_ -match "\*$"
        }
    }

    # Set a variable for each of the power schemes (just to make it more readable)
    $highPerformance = $powerConstants["SCHEME_MIN"]
    $balanced = $powerConstants["SCHEME_BALANCED"]

    # Get current active power plan
    $setPowerPlan = $powerSchemes | Where-Object { $_.IsActive }
    $setPowerPlan = $setPowerPlan.Guid

    # Regex to get the GUID
    if ($setPowerPlan -match "\w{8}-\w{4}-\w{4}-\w{4}-\w{12}") {
        $setPowerPlan = $matches[0]
    }
    else {
        $setPowerPlan = $null
    }

    # Change the power plan based on what power plan is active right now
    if (($setPowerPlan -eq $balanced) -or ($setPowerPlan -eq $highPerformance)) {
        return $false
    } 
    else {
        return $true
    }
}