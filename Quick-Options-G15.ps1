
Param
(
    [String]$Restart
)

If ($Restart -ne "") {
    Start-Sleep 1
}

Set-Location $PsScriptRoot

Self-Elevate

. ".\scripts\Common-Functions.ps1"
. ".\scripts\Power-Plans.ps1"
. ".\scripts\Dell-G15-Scripts.ps1"
. ".\scripts\Create-Tasks.ps1"
. ".\scripts\Battery-Mode.ps1"

$CurrentFolder = split-path $MyInvocation.MyCommand.Path

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  	 | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 	 | out-null
[System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | out-null
[System.Reflection.Assembly]::LoadFrom("$CurrentFolder\assembly\MahApps.Metro.dll") | out-null
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\CompMgmtLauncher.exe")	


# ----------------------------------------------------
# Part - User GUI
# ----------------------------------------------------

[xml]$XAMLUsers =  
@"
<Controls:MetroWindow 
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	xmlns:i="http://schemas.microsoft.com/expression/2010/interactivity"		
	xmlns:Controls="clr-namespace:MahApps.Metro.Controls;assembly=MahApps.Metro"
	Title="Quick Config Options" Width="470" ResizeMode="NoResize" Height="300" ShowCloseButton="False" 
	BorderBrush="DodgerBlue" BorderThickness="0.5" WindowStartupLocation ="CenterScreen">

    <Window.Resources>
        <ResourceDictionary>
            <ResourceDictionary.MergedDictionaries>
				<ResourceDictionary Source="$CurrentFolder\resources\Icons.xaml" /> 
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Fonts.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Colors.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Accents/Cobalt.xaml" />
                <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Accents/BaseLight.xaml" />
            </ResourceDictionary.MergedDictionaries>
        </ResourceDictionary>
    </Window.Resources>

    <Grid>
    <Label Content="Options" HorizontalAlignment="Left" Margin="10,3,0,0" VerticalAlignment="Top" Width="112"/>
    <CheckBox x:Name="Awcc" Content="Alienware Command Center" HorizontalAlignment="Left" Margin="10,32,0,0" VerticalAlignment="Top" Height="20"/>
    <CheckBox x:Name="Killer" Content="Killer Services" HorizontalAlignment="Left" Margin="10,60,0,0" VerticalAlignment="Top"/>
    <CheckBox x:Name="Nahimic" Content="Nahimic Services" HorizontalAlignment="Left" Margin="10,87,0,0" VerticalAlignment="Top"/>
    <CheckBox x:Name="Nvidia" Content="Nvidia Broadcast Service" HorizontalAlignment="Left" Margin="10,115,0,0" VerticalAlignment="Top"/>
    <CheckBox x:Name="Battery" Content="Battery Mode" HorizontalAlignment="Left" Margin="10,142,0,0" VerticalAlignment="Top"/>
    <CheckBox x:Name="AlienFXTools" Content="Budget Alienware Software" HorizontalAlignment="Left" Margin="10,170,0,0" VerticalAlignment="Top"/>
    </Grid>
</Controls:MetroWindow>
"@
$MainWindow = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $XAMLUsers))

$Awcc = $MainWindow.FindName('Awcc')
$Killer = $MainWindow.FindName('Killer')
$Nahimic = $MainWindow.FindName('Nahimic')
$Nvidia = $MainWindow.FindName('Nvidia')
$Battery = $MainWindow.FindName('Battery')
$AlienFXTools = $MainWindow.FindName('AlienFXTools')

# Status
# Here we are chekcking if the services/programs are active

function Assert-Service-Running {
    param (
        [string] $ServiceName
    )
    $arrService = Get-Service -Name $ServiceName
    return $arrService.Status -eq 'Running'
}

function Fill-Check-Boxes {
    $Awcc.IsChecked = Assert-Service-Running 'AWCCService'
    $Killer.IsChecked = Assert-Service-Running 'KAPSService'
    $Nahimic.IsChecked = Assert-Service-Running 'NahimicService'

    $nvidiaBroadcastUiProcessUI = Get-Process "NVIDIA Broadcast UI" -ErrorAction SilentlyContinue
    $NvidiaBroadcastProcess = Get-Process "NVIDIA Broadcast" -ErrorAction SilentlyContinue
    if ($nvidiaBroadcastUiProcessUI -or $NvidiaBroadcastProcess -or (Assert-Service-Running 'NvBroadcast.ContainerLocalSystem')) {
        $Nvidia.IsChecked = $true
    }

    $Battery.IsChecked = Assert-Power-Plan-Battery-Mode

    $AlienFX = Get-Process "alienfx-gui" -ErrorAction SilentlyContinue
    $AlienFan = Get-Process "alienfan-gui" -ErrorAction SilentlyContinue
    if ($AlienFX -or $AlienFan) {
        $AlienFXTools.IsChecked = $true
    }
}

Fill-Check-Boxes

########################## Events ############################
$Awcc.Add_Click({
        if ($Awcc.IsChecked) {
            Set-AWCC-State "enable"
            "AWCC is now running" | Show-Notification -ToastTitle 'Alienware Command Center'        
        }
        else {
            Set-AWCC-State "disable"
            "AWCC is stopped" | Show-Notification -ToastTitle 'Alienware Command Center'
        }
    })

$Killer.Add_Click({
        if ($Killer.IsChecked) {
            Set-Killer-Services-State "enable"
            "Killer Software is now running" | Show-Notification -ToastTitle 'Killer Software'
        }
        else {
            Set-Killer-Services-State "disable"
            "Killer Software is now stopped" | Show-Notification -ToastTitle 'Killer Software'
        }
    })

$Nahimic.Add_Click({
        if ($Nahimic.IsChecked) {
            Set-Nahimic-Services-State "enable"
            "Nahimic is now running" | Show-Notification -ToastTitle 'Nahimic Audio'
        }
        else {
            Set-Nahimic-Services-State "disable"
            "Nahimic is now stopped" | Show-Notification -ToastTitle 'Nahimic Audio'
        }
    })

# Nvidia Broadcast Handler
$Nvidia.Add_Click({
        if ($Nvidia.IsChecked) {
            Set-NVIDIA-BroadCast-State "enable"
            "Nvidia Broadcast Svc is now running" | Show-Notification -ToastTitle 'Nvidia Broadcast'
        }
        else {
            Set-NVIDIA-BroadCast-State "disable"
            "Nvidia Broadcast Svc is now stopped" | Show-Notification -ToastTitle 'Nvidia Broadcast'
        }
    })

# Battery Handler
$Battery.Add_Click({
        if ($Battery.IsChecked) {
            & ".\scripts\Battery-Mode.ps1" "start"
            "Power Plan is now on Battery mode" | Show-Notification -ToastTitle 'Power Mode Changed'
        }
        else {
            & ".\scripts\Battery-Mode.ps1" "stop"
            "Power Plan is now on balanced mode" | Show-Notification -ToastTitle 'Power Mode Changed'
        }
    })

# Budget Alienware Software Handler
$AlienFXTools.Add_Click({
        if ($AlienFXTools.IsChecked) {
            Set-Alien-Tools-State "enable"
            "Budget AWCC is running" | Show-Notification -ToastTitle 'Budget AWCC'
        }
        else {
            Set-Alien-Tools-State "disable"
            "Budget AWCC has stopped" | Show-Notification -ToastTitle 'Budget AWCC'
        }
    })

################################################################################################################################"
# ACTIONS FROM THE SYSTRAY
################################################################################################################################"

# ----------------------------------------------------
# Part - Add the systray menu
# ----------------------------------------------------		
	
$MainToolIcon = New-Object System.Windows.Forms.NotifyIcon
$MainToolIcon.Text = "Dell G15"
$MainToolIcon.Icon = $icon
$MainToolIcon.Visible = $true

$Menu_Exit = New-Object System.Windows.Forms.MenuItem
$Menu_Exit.Text = "Exit"

$contextmenu = New-Object System.Windows.Forms.ContextMenu
$MainToolIcon.ContextMenu = $contextmenu
$MainToolIcon.contextMenu.MenuItems.AddRange($Menu_Exit)


# ---------------------------------------------------------------------
# Action when after a click on the systray icon
# ---------------------------------------------------------------------
$MainToolIcon.Add_Click({
        [System.Windows.Forms.Integration.ElementHost]::EnableModelessKeyboardInterop($MainWindow)
        If ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
            $MainWindow.WindowStartupLocation = "CenterScreen"	
            $MainWindow.Show()
            $MainWindow.Activate()

            Fill-Check-Boxes
        }
    })

# ---------------------------------------------------------------------
# Action after clicking on the User GUI
# ---------------------------------------------------------------------

$MainWindow.Add_MouseDoubleClick({
    })

$MainWindow.Add_MouseLeftButtonDown({
    })

# Close the window if it loses focus
$MainWindow.Add_Deactivated({
        $MainWindow.Hide()	
    })

# When Exit is clicked, close everything and kill the PowerShell process
$Menu_Exit.add_Click({
        $MainToolIcon.Visible = $false
        Stop-Process $pid
    })

# Make PowerShell Disappear
$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)

# Force garbage collection just to start slightly lower RAM usage.
[System.GC]::Collect()

# Create an application context for it to all run within.
# This helps with responsiveness, especially when clicking Exit.
$appContext = New-Object System.Windows.Forms.ApplicationContext
[void][System.Windows.Forms.Application]::Run($appContext)