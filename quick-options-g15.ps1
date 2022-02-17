
Param
(
    [String]$Restart	
)

If ($Restart -ne "") {
    Start-Sleep 1
} 

Set-Location $PsScriptRoot

# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

. ".\common_functions.ps1"

$Current_Folder = split-path $MyInvocation.MyCommand.Path
	
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  	 | out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 	 | out-null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing') 		 | out-null
[System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | out-null
[System.Reflection.Assembly]::LoadFrom("$Current_Folder\assembly\MahApps.Metro.dll") | out-null

$icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Windows\System32\CompMgmtLauncher.exe")	


# ----------------------------------------------------
# Part - User GUI
# ----------------------------------------------------

[xml]$XAML_Users =  
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
				<ResourceDictionary Source="$Current_Folder\resources\Icons.xaml" /> 
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
    <CheckBox x:Name="awcc" Content="Alienware Command Center" HorizontalAlignment="Left" Margin="10,32,0,0" VerticalAlignment="Top" Height="20"/>
    <CheckBox x:Name="killer" Content="Killer Services" HorizontalAlignment="Left" Margin="10,60,0,0" VerticalAlignment="Top"/>
    <CheckBox x:Name="nahimic" Content="Nahimic Services" HorizontalAlignment="Left" Margin="10,87,0,0" VerticalAlignment="Top"/>
    <CheckBox x:Name="nvidia" Content="Nvidia Broadcast Service" HorizontalAlignment="Left" Margin="10,115,0,0" VerticalAlignment="Top"/>
    <CheckBox x:Name="battery" Content="Battery Mode" HorizontalAlignment="Left" Margin="10,142,0,0" VerticalAlignment="Top"/>
    <CheckBox x:Name="budget" Content="Budget Alienware Software" HorizontalAlignment="Left" Margin="10,170,0,0" VerticalAlignment="Top"/>
    </Grid>
</Controls:MetroWindow>        
"@
$Main_Window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $XAML_Users))

$awcc = $Main_Window.FindName('awcc')
$killer = $Main_Window.FindName('killer')
$nahimic = $Main_Window.FindName('nahimic')
$nvidia = $Main_Window.FindName('nvidia')
$battery = $Main_Window.FindName('battery')
$budget = $Main_Window.FindName('budget')

# Status
$ServiceName = 'AWCCService'
$arrService = Get-Service -Name $ServiceName
$awcc.IsChecked = ($arrService.Status -eq 'Running')

$ServiceName = 'KAPSService'
$arrService = Get-Service -Name $ServiceName
$killer.IsChecked = ($arrService.Status -eq 'Running')

$ServiceName = 'NahimicService'
$arrService = Get-Service -Name $ServiceName
$nahimic.IsChecked = ($arrService.Status -eq 'Running')

$ServiceName = 'NvBroadcast.ContainerLocalSystem'
$arrService = Get-Service -Name $ServiceName
# NVIDIA Broadcast UI.exe
$nvidiaBroadcastUiProcessUI = Get-Process "NVIDIA Broadcast UI" -ErrorAction SilentlyContinue
$nvidiaBroadcastUiProcess = Get-Process "NVIDIA Broadcast" -ErrorAction SilentlyContinue
if ($nvidiaBroadcastUiProcessUI -or $nvidiaBroadcastUiProcess -or ($arrService.Status -eq 'Running')) {
    $nvidia.IsChecked = $true
}

$battery.IsChecked = Assert-Power-Plan-Battery-Mode

$alien_fx = Get-Process "alienfx-gui" -ErrorAction SilentlyContinue
$alien_fan = Get-Process "alienfan-gui" -ErrorAction SilentlyContinue
if ($alien_fx -or $alien_fan) {
    $budget.IsChecked = $true
}

# Events
# AWCC Handler
$awcc.Add_Checked({
        & ".\alienware_command_center.ps1" "start"
        "AWCC is now running" | Show-Notification -ToastTitle 'Alienware Command Center'
    })
$awcc.Add_UnChecked({
        & ".\alienware_command_center.ps1" "stop"
        "AWCC is stopped" | Show-Notification -ToastTitle 'Alienware Command Center'
    })

# Killer Handler
$killer.Add_Checked({
        & ".\killer_services.ps1" "start"
        "Killer Software is now running" | Show-Notification -ToastTitle 'Killer Software'
    })
$killer.Add_UnChecked({
        & ".\killer_services.ps1" "stop"
        "Killer Software is now stopped" | Show-Notification -ToastTitle 'Killer Software'
    })

# Nahimic Handler
$nahimic.Add_Checked({
        & ".\nahimic_service.ps1" "start"
        "Nahimic is now running" | Show-Notification -ToastTitle 'Nahimic Audio'
    })
$nahimic.Add_UnChecked({
        & ".\nahimic_service.ps1" "stop"
        "Nahimic is now stopped" | Show-Notification -ToastTitle 'Nahimic Audio'
    })

# Nvidia Broadcast Handler
$nvidia.Add_Checked({
        & ".\nvidia_broadcast.ps1" "start"
        "Nvidia Broadcast Svc is now running" | Show-Notification -ToastTitle 'Nvidia Broadcast'
    })
$nvidia.Add_UnChecked({
        & ".\nvidia_broadcast.ps1" "stop"
        "Nvidia Broadcast Svc is now stopped" | Show-Notification -ToastTitle 'Nvidia Broadcast'
    })

# Battery Handler
$battery.Add_Checked({
        & ".\battery_mode.ps1" "start"
        "Power Plan is now on battery mode" | Show-Notification -ToastTitle 'Power Mode Changed'
    })
$battery.Add_UnChecked({
        & ".\battery_mode.ps1" "stop"
        "Power Plan is now on balanced mode" | Show-Notification -ToastTitle 'Power Mode Changed'
    })

# Budget Alienware Software Handler
$budget.Add_Checked({
        & ".\budget_alienware_software.ps1" "start"
        "Budget AWCC is running" | Show-Notification -ToastTitle 'Budget AWCC'
    })
$budget.Add_UnChecked({
        & ".\budget_alienware_software.ps1" "stop"
        "Budget AWCC has stopped" | Show-Notification -ToastTitle 'Budget AWCC'
    })

################################################################################################################################"
# ACTIONS FROM THE SYSTRAY
################################################################################################################################"

# ----------------------------------------------------
# Part - Add the systray menu
# ----------------------------------------------------		
	
$Main_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
$Main_Tool_Icon.Text = "QOpt"
$Main_Tool_Icon.Icon = $icon
$Main_Tool_Icon.Visible = $true

$Menu_Users = New-Object System.Windows.Forms.MenuItem
$Menu_Users.Text = "Quick Options"

$Menu_Exit = New-Object System.Windows.Forms.MenuItem
$Menu_Exit.Text = "Exit"

$contextmenu = New-Object System.Windows.Forms.ContextMenu
$Main_Tool_Icon.ContextMenu = $contextmenu
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Users)
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Exit)


# ---------------------------------------------------------------------
# Action when after a click on the systray icon
# ---------------------------------------------------------------------
$Main_Tool_Icon.Add_Click({					
        [System.Windows.Forms.Integration.ElementHost]::EnableModelessKeyboardInterop($Main_Window)
        If ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
            $Main_Window.WindowStartupLocation = "CenterScreen"	
            $Main_Window.Show()
            $Main_Window.Activate()
        }				
    })



# ---------------------------------------------------------------------
# Action after clicking on User Analysis
# ---------------------------------------------------------------------
$Menu_Users.Add_Click({	
        $Main_Window.WindowStartupLocation = "CenterScreen"	
        [System.Windows.Forms.Integration.ElementHost]::EnableModelessKeyboardInterop($Main_Window)
        $Main_Window.ShowDialog()
        $Main_Window.Activate()	
    })

# ---------------------------------------------------------------------
# Action after clicking on the User GUI
# ---------------------------------------------------------------------

$Main_Window.Add_MouseDoubleClick({
    })

$Main_Window.Add_MouseLeftButtonDown({
    })

# Close the window if it loses focus
$Main_Window.Add_Deactivated({
        $Main_Window.Hide()	
        #$CustomDialog.RequestCloseAsync()
        # Close_modal_progress	
    })

# Action on the close button
$Main_Window.Add_Closing({
        $_.Cancel = $true
        # [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Main_Window, "Oops :-(", "To close the window click out of the window !!!")					
    })

# When Exit is clicked, close everything and kill the PowerShell process
$Menu_Exit.add_Click({
        $Main_Tool_Icon.Visible = $false
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