Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "powershell.exe -ExecutionPolicy Bypass -File ""C:\SpeedtestCLI\speedtest_logger.ps1""", 0, False
