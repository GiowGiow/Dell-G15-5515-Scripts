. ".\Common-Functions.ps1"

function Register-Battery-Mode-Task {
    param (
        [string] $TaskName,
        [string] $Description,
        [string] $BatteryModeState,
        [string] $EventToListen,
        [PSCredential] $Credentials
    )
    # Task Action - VBS Script
    $WScriptExePath = "C:\Windows\System32\wscript.exe"
    $CurrentFolder = split-path $MyInvocation.MyCommand.Path
    $BatteryScriptPath = "$CurrentFolder\Battery-Mode.vbs"
    $Action = New-ScheduledTaskAction -Execute $WScriptExePath -Argument "$BatteryScriptPath $BatteryModeState"

    # Task that triggers on event: Lost AC adapter
    $CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger `
        -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger

    $Trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
    $Trigger.Enabled = $True 
    $Trigger.Subscription = $EventToListen

    # Username and Password
    $Username = $Credentials.UserName
    $Password = $Credentials.GetNetworkCredential().Password
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    # Register Task
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger `
        -RunLevel Highest `-Description $Description -User $Username `
        -Password $Password -Settings $settings
}

function Register-Battery-Mode-Start-Task {
    param (
        [PSCredential] $Credentials
    )
    $TaskName = "Battery Mode Start"
    $Description = "Starts battery mode optimizations"
    $BatteryModeState = "start"
    $EventToListen = @"
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[(EventID=105)]] and *[System[Provider[@Name="Microsoft-Windows-Kernel-Power"]]] and *[EventData[Data[@Name="AcOnline"] and (Data='false')]]</Select>
  </Query>
</QueryList>
"@
    Register-Battery-Mode-Task -TaskName $TaskName -Description $Description `
        -BatteryModeState $BatteryModeState -Event $EventToListen -Credentials $Credentials
}

function Register-Battery-Mode-Stop-Task {
    param (
        [PSCredential] $Credentials
    )
    $TaskName = "Battery Mode Stop"
    $Description = "Stops battery mode optimizations"
    $BatteryModeState = "stop"
    $EventToListen = @"
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[(EventID=105)]] and *[System[Provider[@Name="Microsoft-Windows-Kernel-Power"]]] and *[EventData[Data[@Name="AcOnline"] and (Data='true')]]</Select>
  </Query>
</QueryList>
"@
    Register-Battery-Mode-Task -TaskName $TaskName -Description $Description `
        -BatteryModeState $BatteryModeState -Event $EventToListen -Credentials $Credentials
}

function Register-Tasks {
    # User and Pass is needed to run with highest privileges
    $Credentials = Get-User-Credentials
    Register-Battery-Mode-Stop-Task -Credentials $Credentials
    Register-Battery-Mode-Start-Task -Credentials $Credentials
}

