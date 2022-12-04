if WScript.Arguments.Count = 1 Then
    ' Get the argument
    arg = WScript.Arguments(0)
    ' Call the script silently using vbs shenanigans
    Dim shell,command
    command = "powershell.exe -nologo -command ""C:\scripts\power-saving-scripts\battery_mode.ps1 " & arg & """"
    Set shell = CreateObject("WScript.Shell")
    shell.Run command,0
End If