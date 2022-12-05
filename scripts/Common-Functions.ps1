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

    $Notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Power Status")
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
        $ExecutablePath,
        [string]
        $ProgramName
    )

    $isRunning = (Get-Process | Where-Object { $_.Name -eq $ProgramName }).Count -gt 0
    if (!$isRunning) {
        Write-Host "Starting $ProgramName..."
        Start-Process -WindowStyle Minimized "$ExecutablePath"
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
    # Set battery saver mode (Windows 10/11) to start on battery at a certain battery threshold
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
    $ChangeScreenResolutionBinPath = "..\bin\ChangeScreenResolution.exe"
    & $ChangeScreenResolutionBinPath "/d=$LaptopDisplayNumber" "/f=$DisplayFrequency" > $null 2>&1
}

function Get-User-Credentials {
    $Msg = "Enter the username and password that will run the task";
    $Credentials = $Host.UI.PromptForCredential("Task username and password", $Msg, `
            "$env:userdomain\$env:username", $env:userdomain)
    return $Credentials
}

function Assert-Power-Plan-Battery-Mode {
    # List power profile schemes
    $PowerConstants = @{}
    PowerCfg.exe -ALIASES | Where-Object { $_ -match 'SCHEME_' } | ForEach-Object {
        $guid, $alias = ($_ -split '\s+', 2).Trim()
        $PowerConstants[$alias] = $guid 
    }

    # Get a list of power schemes and check the one that is active
    $powerSchemes = PowerCfg.exe -LIST | Where-Object { $_ -match '^GUID' } | ForEach-Object {
        $guid = $_ -replace '.*GUID:\s*([-a-f0-9]+).*', '$1'
        [PsCustomObject]@{
            Name     = $_.Trim("* ") -replace '.*\(([^)]+)\)$', '$1'          # LOCALIZED !
            Alias    = $PowerConstants[$guid]
            Guid     = $guid
            IsActive = $_ -match '\*$'
        }
    }

    # Set a variable for each of the power schemes (just to make it more readable)
    $highPerformance = $PowerConstants['SCHEME_MIN']
    $balanced = $PowerConstants['SCHEME_BALANCED']

    # Get current active power plan
    $setPowerPlan = $powerSchemes | Where-Object { $_.IsActive }
    $setPowerPlan = $setPowerPlan.Guid

    # Regex to get the GUID
    if ($setPowerPlan -match '\w{8}-\w{4}-\w{4}-\w{4}-\w{12}') {
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

function Assert-PowerPlan-Exists {
    Param (
        [string] $PowerPlan
    )

    $PowerPlanExists = PowerCfg.exe -LIST | Where-Object { $_ -match '^GUID' } | ForEach-Object {
        $GuidStr = $_ -replace '.*GUID:\s*([-a-f0-9]+).*', '$1'
        $Guid = if ($GuidStr -match '\w{8}-\w{4}-\w{4}-\w{4}-\w{12}') { 
            $matches[0] 
        }
        if ($Guid -eq $PowerPlan) {
            return $true
        }
    }

    if ($PowerPlanExists) {
        return $true
    }
    return $false
}
