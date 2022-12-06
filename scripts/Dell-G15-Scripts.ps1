. "$PSScriptRoot\Common-Functions.ps1"

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

    $UIExeName = "NVIDIA Broadcast UI.exe"
    $ExeName = "NVIDIA Broadcast.exe"

    $ExePath = "C:\Program Files\NVIDIA Corporation\NVIDIA Broadcast\$ExeName"
    $NvidiaBroadcastServiceName = "NvBroadcast.ContainerLocalSystem"
    $NvidiaBroadcastTaskName = "NvBroadcast_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"

    If ($State -eq "enable") {
        # You need this service to access the camera, mic and so on
        Set-Service-State -State $State -SvcName $NvidiaBroadcastServiceName
        & $ExePath
    }
    elseif ($State -eq "disable") {
        # This tasks runs when you logon and it starts Broadcast UI minimized
        Disable-ScheduledTask -TaskName $NvidiaBroadcastTaskName
        taskkill /IM "$UIExeName" /F /FI "STATUS ne UNKNOWN"
        taskkill /IM "$ExeName" /F /FI "STATUS ne UNKNOWN"
        Set-Service-State -State $State -SvcName $NvidiaBroadcastServiceName
    }
    else {
        Write-Host ("Not a valid state")
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

function Set-Laptop-Display-Hz {
    # Set monitor to defined Hz using this binary
    # from: https://tools.taubenkorb.at/change-screen-resolution/
    Param (
        [string] $LaptopDisplayNumber,
        [string] $DisplayFrequency
    )
    $ParentDir = Split-Path $PSScriptRoot
    $ChangeScreenResolutionBinPath = "$ParentDir\bin\ChangeScreenResolution.exe"
    Write-Host $ChangeScreenResolutionBinPath
    & $ChangeScreenResolutionBinPath "/d=$LaptopDisplayNumber" "/f=$DisplayFrequency"
}

function Set-Software-Battery-Mode-Aggressive {
    param (
        [string] $State # Should be AC or Battery
    )
    If ($State -eq "AC") {
        $SoftwareToLoad = @(`
                Tuple "C:\Users\gioma\Documents\utilities\clickmonitorddc\ClickMonitorDDC_7_2.exe" "Click Monitor DDC", `
                Tuple "C:\Program Files\Rainmeter\Rainmeter.exe" "Rainmeter", `
                Tuple "C:\Program Files\WindowsApps\40459File-New-Project.EarTrumpet_2.2.0.0_x86__1sdd7yawvg6ne\EarTrumpet\EarTrumpet.exe" "EarTrumpet", `
                Tuple "C:\Users\gioma\AppData\Local\Programs\AutoDarkMode\AutoDarkModeSvc.exe" "AutoDarkModeSvc", `
                Tuple "C:\Program Files (x86)\Steam\steamapps\common\wallpaper_engine\wallpaper32.exe" "wallpaper32", `
                Tuple "C:\Users\gioma\AppData\Local\Programs\ElevenClock\ElevenClock.exe" "ElevenClock")

        foreach ($Software in $SoftwareToLoad) {
            Write-Host "Loading" $Software.Item2 "..."
            Start-Program-If-Not-Running $Software.Item1 $Software.Item2
        }

        Set-NVIDIA-BroadCast-State "enable"
    }
    elseif ($action -eq "Battery") {
        $SoftwareToKill = @("Rainmeter.exe", "ClickMonitorDDC_7_2.exe", "EarTrumpet.exe", `
                "AutoDarkModeSvc.exe", "Rainmeter.exe", "ElevenClock.exe", "PhoneExperienceHost.exe", `
                "YourPhoneAppProxy.exe")

        foreach ($Software in $SoftwareToKill) {
            Write-Host "Stopping $Software..."
            taskkill /IM $Software /F /FI "STATUS ne UNKNOWN"
        }

        Set-NVIDIA-BroadCast-State "disable"
    }
    else {
        Write-Host ("Not a valid action")
    }
}

function Set-Alien-Tools-State {
    param (
        [string] $State
    )

    $AlienFxExePath = "C:\Program Files\AlienFX Tools\alienfx-gui.exe"

    If ($State -eq "enable") {
        Start-Program-If-Not-Running $AlienFxExePath "alienfx-gui"
    }
    elseif ($State -eq "disable") {
        taskkill /IM "alienfx-gui.exe" /F /FI "STATUS ne UNKNOWN"
    }
    else {
        Write-Host ("Not a valid state")
    }
}

$Ryzen5800hTDPs = New-Object PSObject -Property @{
    TDP15 = "--tctl-temp=70 --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000"
    TDP20 = "--tctl-temp=70 --stapm-limit=25000 --fast-limit=25000 --slow-limit=25000"
    TDP35 = "--tctl-temp=80 --stapm-limit=35000 --fast-limit=35000 --slow-limit=35000"
    TDP45_80C = "--tctl-temp=80 --stapm-limit=45000 --fast-limit=48000 --slow-limit=65000"
    TDP45_85C = "--tctl-temp=85 --stapm-limit=45000 --fast-limit=48000 --slow-limit=65000"
    TDP60_90C = "--tctl-temp=90 --stapm-limit=60000 --fast-limit=62000 --slow-limit=68000"
}

function Change-TDP {
    param (
        [string] $StrProfile
    )
    $Parameters = $StrProfile.Split(" ")
    $ParentDir = Split-Path $PSScriptRoot
    $RyzenADJBinPath = "$ParentDir\bin\ryzenadj-win64\ryzenadj.exe"
    & $RyzenADJBinPath $Parameters
}
