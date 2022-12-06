. "$PSScriptRoot\Common-Functions.ps1"

$EventsToQuery = New-Object PSObject -Property @{
    # List of interesting events that we can query on Windows to execute tasks
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
}

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
    $BatteryScriptPath = "$PSScriptRoot\Battery-Mode.vbs"
    $Action = New-ScheduledTaskAction -WorkingDirectory $PSScriptRoot -Execute $WScriptExePath -Argument "$BatteryScriptPath $BatteryModeState"

    # Task that triggers on event: Lost AC adapter
    $CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger

    $Trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
    $Trigger.Enabled = $True 
    $Trigger.Subscription = $EventToListen

    # Username and Password
    $Username = "$env:userdomain\$env:username"
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    # Register Task
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger `
        -RunLevel Highest -Description $Description -User $Username `
        -Settings $Settings
}

function Register-Battery-Mode-Start-Task {
    $TaskName = "Battery Mode Start"
    $Description = "Starts battery mode optimizations"
    $BatteryModeState = "start"
    $EventToListen = @"
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[(EventID=105)]] and *[System[Provider[@Name="Microsoft-Windows-Kernel-Power"]]] and *[EventData[Data[@Name="AcOnline"]]]</Select>
  </Query>
</QueryList>
"@
    Register-Battery-Mode-Task -TaskName $TaskName -Description $Description -BatteryModeState $BatteryModeState -Event $EventToListen
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
