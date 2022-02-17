# Quick Options for DELL G15

![quick-options](./quick-options.png)

A small app written using powershell scripting language to enable and disable services and apps for the DELL-G15 5515.
This apps lives on the tray and performs common tasks you want to do, avoiding the use of scripts.

![quick-options](./taskbar.png)

This allows more flexibility when using on laptop on battery, where you want every use of resource minimized, or when connected to the AC, where we can worry less about resource consumption.


# Features

It currently does the following operations:

- Disable/Enable a Battery Mode
    - This options sets the screen to 90Hz (you need to enable this mode with CRU first)
    - Disables Turbo Boost 
    - Enables Power Saver mode on windows.

- Disable/Enable Nahimic Services
    - This service provides some audio enhancements for the DELL G15 (specially when using internal speakers), but is often unecessary when using headphones or speakers and it is quite heavy.

- Disable/Enable Killer Software
    - Killer is the software for the internal wi-fi card, it comes bloated with services and software, other than the driver itself, it does provide some advanced configuration over the wi-fi card, but I never used. 

- Disable/Enable Nvidia Broadcast Services
    - Nvidia Broadcast is an awesome software, but it used a service in the background to have permissions to access the mic and camera. You don't need this running all the time, only when actually using it.

- Disable/Enable Alienware Command Center
    - Alienware command center is by nature bloated and buggy, but often it runs the laptop fine enough.

- Disable/Enable Budget Alienware Software
    - [AlienFx-Tools](https://github.com/T-Troll/alienfx-tools) by T-Troll is a custom implementation of the Alienware Command Center, it works well enough, it has some bugs here and there and the translation to english is lacking. In spite of all that it has 100x less impact on the ram and it uses less CPU. So it is a great tool to have on battery. 

