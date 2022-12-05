if WScript.Arguments.Count = 1 Then
    ' Get the argument
    action = WScript.Arguments(0)
    ' Call the script silently using vbs shenanigans
    Dim shell,command
    strCommand = "powershell.exe -nologo -command "".\Battery-Mode.ps1 " & action & """"
    Set shell = CreateObject("WScript.Shell")
    shell.Run strCommand,0
End If