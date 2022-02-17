# Quick Options for DELL G15

![quick-options](./quick-options.png)

A small app written using powershell scripting language to enable and disable services, apps and tasks for the DELL-G15 5515.

This apps lives on the tray and performs common tasks you may want to do, avoiding the use of scripts or the terminal.

![quick-options](./taskbar.png)

It allows more flexibility when using on laptop on battery, where you want every use of resources minimized, or when connected to the AC, where we can worry less about resource consumption.

# Features

It currently does the following operations:

- Disable/Enable a custom optimized Battery Mode
    - This options sets the screen to 90Hz (you need to enable this mode with CRU first)
    - Disables Turbo Boost (using a already configured power plan)
    - Enables Power Saver mode on Windows 11 (only works when disconnected from the AC).
    - Kills programs that keep updating in the background or are not needed on battery like Rainmeter and ClickMonitorDDC, they will reopen when battery mode is disabled.

- Disable/Enable Nahimic Services
    - This quite heavy app/service provides some audio enhancements for the DELL G15 (specially when using internal speakers), but is often unecessary/annoying when using headphones or speakers.

- Disable/Enable Killer Software
    - Killer Services/Software is the software for the internal wi-fi card, it comes bloated with services and software, other than the driver itself, it does provide some advanced configuration over the wi-fi card, but I never used, they can be disabled and do not affect the wi-fi driver. 

- Disable/Enable Alienware Command Center
    - Alienware command center is by nature bloated and buggy, but often it runs the laptop fine enough.

- Disable/Enable Budget Alienware Software
    - [AlienFx-Tools](https://github.com/T-Troll/alienfx-tools) by T-Troll is a custom implementation of the Alienware Command Center, it works well enough, it has some bugs here and there and the translation to english is lacking. In spite of all that it has 100x less impact on the ram and it uses less CPU. So it is a great tool to have running on battery.

- Disable/Enable Nvidia Broadcast Services
    - Nvidia Broadcast is an awesome software, but it uses a service in the background to have permissions to access the mic and camera. You don't need this running all the time, only when actually using it.  

# How to use
Run the quick-options-g15.ps1 with PowerShell using the context menu or using the terminal, it needs administrator rights to disable/enable services, so if needed it will try to elevate its shell.

You can set a Windows Task to run this script on startup.

## Other software used or expected to be installed

- [AlienFx-Tools](https://github.com/T-Troll/alienfx-tools) is expected to be downloaded and configured, used as a replacement for AWCC on battery, you can check their github on how to do that.

- [Change-Screen-Resolution](https://tools..at/change-screen-resolution/) to change monitor Hz

In my setup I made the battery mode kill(and rerun when needed) some apps running in the background like Rainmeter and Click Monitor DDC. Those options and scripts are easily customizable and have comments on them so anyone can kill/run any application they want to have better battery performance.

Each option in the menu have their own PowerShell script file that determines what will happen when you click the option in the GUI. 

## Tutorials/Guides of interest to G15 owners 

In my battery profile setup I change to the battery power plan, a lot of the settings I based on this [guide here](https://www.reddit.com/r/AcerNitro/comments/rfwjah/how_i_achieved_12_hours_battery_lifeguide/), like disabling turbo boost.

I tested and found that using efficient aggressive for boost mode on the power plan settings didn't affect at all the boost, it kept running as aggressive. 

