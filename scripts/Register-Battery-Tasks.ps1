. "$PSScriptRoot\Common-Functions.ps1"

$EventsToQuery = New-Object PSObject -Property @{
    # List of interesting events that we can query on Windows to execute tasks
    PowerConnectOrDisconnect = @"
    <QueryList>
      <Query Id="0" Path="System">
        <Select Path="System">*[System[(EventID=105)]] and *[System[Provider[@Name="Microsoft-Windows-Kernel-Power"]]] and *[EventData[Data[@Name="AcOnline"]]]</Select>
      </Query>
    </QueryList>
"@
    DisconnectedFromPower = @"
    <QueryList>
      <Query Id="0" Path="System">
        <Select Path="System">*[System[(EventID=105)]] and *[System[Provider[@Name="Microsoft-Windows-Kernel-Power"]]] and *[EventData[Data[@Name="AcOnline"] and (Data='false')]]</Select>
      </Query>
    </QueryList>
"@
    ConnectedToPower = @"
    <QueryList>
      <Query Id="0" Path="System">
        <Select Path="System">*[System[(EventID=105)]] and *[System[Provider[@Name="Microsoft-Windows-Kernel-Power"]]] and *[EventData[Data[@Name="AcOnline"] and (Data='true')]]</Select>
      </Query>
    </QueryList>
"@
    AfterSupensionOrHibernation = @"
    <QueryList>
    <Query Id="0" Path="System">
      <Select Path="System">*[System[Provider[@Name='Microsoft-Windows-Power-Troubleshooter' or @Name='Pow'] and (EventID=1)]]</Select>
    </Query>
  </QueryList>
"@
}

function Create-Event-Trigger {
    param (
        [string] $EventToListen
    )
    $CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
    $Trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
    $Trigger.Subscription = $EventToListen
    $Trigger.Enabled = $True 
    return $Trigger
}

function Register-Battery-Mode-Task {
    param (
        [string] $TaskName,
        [string] $Description,
        [string] $BatteryModeState,
                 $Triggers,
        [PSCredential] $Credentials
    )
    # Check if tasks Exists
    $TaskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $TaskName }
    if($TaskExists) {
        Write-Host "Task already Exists"
        return
    }

    # Task Action - VBS Script
    $WScriptExePath = "C:\Windows\System32\wscript.exe"
    $BatteryScriptPath = "$PSScriptRoot\Battery-Mode.vbs"
    $Action = New-ScheduledTaskAction -WorkingDirectory $PSScriptRoot -Execute $WScriptExePath -Argument "$BatteryScriptPath $BatteryModeState"

    # Username and Password
    $Username = "$env:userdomain\$env:username"
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    # Register Task
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Triggers `
        -RunLevel Highest -Description $Description -User $Username `
        -Settings $Settings
}

function Register-Battery-Mode-Start-Task {
    $TaskName = "Battery Mode Start"
    $Description = "Starts battery mode optimizations"
    $BatteryModeState = "apply"
    $EventTrigger = Create-Event-Trigger $EventsToQuery.PowerConnectOrDisconnect
    Register-Battery-Mode-Task -TaskName $TaskName -Description $Description -BatteryModeState $BatteryModeState -Triggers $EventTrigger
}

function Register-Battery-Mode-Reapply-Task {
    $TaskName = "Battery Mode Reapply"
    $Description = "Reapply battery mode optimizations"
    $BatteryModeState = "reapply"
    $EventTrigger = Create-Event-Trigger $EventsToQuery.AfterSupensionOrHibernation

    $Triggers = @(
        $(New-ScheduledTaskTrigger -AtLogon),
        $(New-ScheduledTaskTrigger -AtStartup),
        $EventTrigger
    )

    Register-Battery-Mode-Task -TaskName $TaskName -Description $Description -BatteryModeState $BatteryModeState -Triggers $Triggers
}

# Self-Elevate
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

Register-Battery-Mode-Start-Task
Register-Battery-Mode-Reapply-Task