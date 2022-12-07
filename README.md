# Dell G15 5515 Script Collection

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Installing](#installing)
- [Other Scripts](#other_scripts)
- [Additional Software Used](#additional)
- [Personal Software Used](#personal)

## About <a name = "about"></a>

This repository contains a collection of scripts that I use to optimize my DELL G15 5515 Ryzen Edition for battery life on DC and performance on AC.

Currently, my battery runs for **6+ hours**, which for a Ryzen 7 5800H, RTX 3060 and a 165Hz screen is *pretty good*.

The main script code is on `Battery-Mode.ps1`.

When on *battery* it automatically does the following:
```
- Change the power plan to a power saver or a custom one
- Disable/enable services and programs
- Set the screen to 60/90Hz
- Disables turbo boost
- Set Windows to power saver Mode
- Set the CPU TDP to 15/25W
```

When on *AC* it automatically does:
```
- Change the power plan back to a balanced or a custom one
- Enable services and programs again
- Set the screen to 144/165Hz
- Enables turbo boost
- Set the CPU TDP back to default 45W
```
## Getting Started <a name = "getting_started"></a>

These instructions will get this script up and running on your machine. You also need to download some third-party software to run everything properly.

### Prerequisites

Select a folder to install the script. As an example, I will use `C:\power-saving-scripts`. 

Download the repository and extract it to the folder you selected.

It should look like this:

``` powershell
C:\power-saving-scripts\bin\ryzenadj-win64
C:\power-saving-scripts\scripts
```

### Download Third-Party Software

Those tools are needed to actually do some of the functionality we want to automate with the script.

1. [CRU](https://www.monitortests.com/forum/Thread-Custom-Resolution-Utility-CRU)

This software creates custom resolutions for the script to change to, as they do not come by default on the DELL G15 5515.

I created two new custom resolutions with `60Hz` and `90Hz` to use when on battery. And *I recommend* you do so as well.

You can check this video for more information on how to do it:

[![Custom Resolution Utility - tutorial](https://img.youtube.com/vi/z8IxA-kKscA/hqdefault.jpg)](https://www.youtube.com/watch?v=z8IxA-kKscA)

2. [ChangeScreenResolution](https://tools.taubenkorb.at/change-screen-resolution/)

This is a tool that allows you to change the screen frequency. You should **download it** from the link above and **put it in the bin folder**. 

In the end, it should look like this:

``` powershell
bin/ChangeScreenResolution.exe
```

3. [RyzenAdj](https://github.com/FlyGoat/RyzenAdj)

This is used to **change the CPU TDP**, it comes pre-baked with the script, but you can download it from the link above and extract the zip on the bin folder. 

In the end, it should look like this:

``` powershell
bin/ryzenadj-win64/RyzenAdj.exe
```

## Installing <a name = "installing"></a>

**1. Edit the values on the script**

After creating your custom resolution, you need to set the correct values for your Display that correspond to your model. 

Those variables are on `scripts/Battery-Mode.ps1`

I have a *DELL G15 5515* with a *165Hz screen*, and I want to run *90Hz on battery*. 

So I set the following values:

``` powershell
$DisplayHzOnBattery = 90
$DisplayHzDefault = 165
```

**2. Test that you can change your display frequency**

To test that you can change your display frequency, you can run the following command: 

Remember to create the custom resolutions on CRU first and use the frequency value you created (in my case, 90Hz):

Go to the bin folder where the .exe is, Shift + click on the folder to open a Powershell window.
And run the following command:

``` powershell
bin/ChangeScreenResolution.exe /d=0 /f=90
```

If everything goes well, you can go to the next step.

**3. Custom Power Plan (Optional)**

In the scripts folder, I have provided a custom power plan that I use, you can use it or create your own.

For AC it uses the Balanced power plan, and for battery, it uses a slightly tweaked Power Saver power plan with Turbo Boost disabled.

When running on battery the CPU frequencies are more steady and tend to stay in the 2GHz range, which is good for battery life.

To install the power plan, *Shift + click* on the file and run it with Powershell. The new power plan will appear on the Power Options.

``` powershell
Import-Power-Plan.ps1
```

**4. Register the scripts to run on battery and AC**

Run `Register-Battery-Tasks.ps1` with Powershell (right-click the file and click on Run With Powershell), it will register the scripts to run on battery and AC automatically as a Task on Windows.

You can check the tasks on the Task Scheduler, they should look like this:

![Battery Mode Task](./resources/tasks.png)

## Other scripts <a name = "other_scripts"></a>

I made several functions that can be used to enable/disable specific features of the G15, they are listed below.

### DELL G15-5515 Automation

-  **Disable/Enable Software on Battery**

    `function: Set-Software-Battery-Mode`

    Is used to change the behavior of services and apps when on battery. Customize it to your needs.
    In my case, I only use it to change between Rainmeter layouts.

-   **Disable/Enable Nahimic Services**

    `function: Set-Nahimic-Services-State`

    -   This quite heavy app/service provides some audio enhancements for the DELL G15 (especially when using internal speakers) but is often unnecessary/annoying when using headphones or speakers.

-   **Disable/Enable Killer Software**

    `function: Set-Killer-Services-State`

    -   Killer Services/Software is the software for the internal Wi-Fi card, it comes bloated with services and software, other than the driver itself, it does provide some advanced configuration over the wi-fi card, but I never used it. In my experiments, those services can be disabled and do not affect the Wi-Fi card.

-   **Disable/Enable Alienware Command Center**

    `function: Set-AWCC-State`

    -   Disable AWCC and its services. I don't recommend doing it, you lose control over any external lights, fan profiles etc. Use this only if you are sure you don't need it, i.e you have AlienFx-Tools installed and working.

### Third Party Software Automation

-   **Disable/Enable AlienFx-Tools**

    `function: Set-Alien-Tools-State`

    -   [AlienFx-Tools](https://github.com/T-Troll/alienfx-tools) by T-Troll is a custom implementation of the Alienware Command Center, it works well enough, but it has some bugs here and there and the translation to English is lacking. Despite all that, it has 100x less impact on the RAM and it uses less CPU. So it is a great tool to have running on battery.

-   **Disable/Enable Nvidia Broadcast Services**

    `function: Set-NVIDIA-BroadCast-State`

    -   Nvidia Broadcast is a program to enhance the mic, output audio and the Web Cam. It is pretty impressive but uses a service in the background to have permission to access the mic and camera. You don't need this running all the time, only when using it.

-   **Change Rainmeter Layout**

    `function: Set-Software-Battery-Mode`

    -   Rainmeter is a great tool to have on your desktop, it allows you to create custom widgets and layouts. I use it to display the battery percentage, the CPU and GPU temperature and the CPU and GPU usage. I have a different layout for when on battery and when on AC, so I can have more information on AC and less on battery.

### Additional Software Used <a name = "additional"></a>

All the additional software required for the script to work.

-   [CRU](https://www.monitortests.com/forum/Thread-Custom-Resolution-Utility-CRU)

    To create new screen resolutions
-   [ChangeScreenResolution](https://tools.taubenkorb.at/change-screen-resolution/) 

    To change between screen frequencies. It comes pre-baked with the script, but you can download it from the link above.
-   [RyzenAdj](https://github.com/FlyGoat/RyzenAdj)

    To change CPU TDP automatically. It comes pre-baked with the script, but you can download it from the link above.


### Personal Software Used <a name = "personal"></a>

If you see any mention to this software, it is because I use it, but it is not required for the script to work.

- [Rainmeter](https://www.rainmeter.net/)

    To display information on the desktop

- [Nvidia Broadcast](https://www.nvidia.com/en-us/geforce/broadcast/)

    To enhance the mic, output audio and the Web Cam

- [ClickMonitorDDC](https://www.monitortests.com/forum/Thread-ClickMonitorDDC)

    To control the monitor brightness and contrast on multi-monitor setups

- [EarTrumpet](https://github.com/File-New-Project/EarTrumpet)

    Volume Control for Windows

- [Auto Dark Mode](https://github.com/AutoDarkMode/Windows-Auto-Night-Mode)

    Automatically switches between the dark and light theme of Windows 10 and Windows 11

- [Eleven Clock](https://github.com/martinet101/ElevenClock)

    ElevenClock: Customize Windows 11 taskbar clock