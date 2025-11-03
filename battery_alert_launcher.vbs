Set objShell = CreateObject("Wscript.Shell")
objShell.Run "powershell.exe -ExecutionPolicy Bypass -File ""W:\Code\System Scripts\battery_alert.ps1""", 0, False
