@echo off
chcp 65001 >nul

%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c ""%~s0"" ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"
chcp 65001 >nul

set "EdgeExe="
for /f "tokens=2,*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe" /ve 2^>nul ^| findstr /i "REG_SZ"') do set "EdgeExe=%%j"

if not defined EdgeExe set "EdgeExe=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
set "EdgeExe=%EdgeExe:"=%"
set "Args=--disable-features=msFeatureGroupNewLookAndFeelHoldout --enable-features=msForceNoRoundedCornerAndMargin"

reg add "HKLM\SOFTWARE\Classes\MSEdgePDF\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\MSEdgeHTM\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\MSEdgeMHT\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\Microsoft-Edge\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% -- \"%%1\"" /f >nul 2>&1

reg add "HKCU\Software\Classes\MSEdgePDF\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
reg add "HKCU\Software\Classes\MSEdgeHTM\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
reg add "HKCU\Software\Classes\MSEdgeMHT\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
reg add "HKCU\Software\Classes\Microsoft-Edge\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% -- \"%%1\"" /f >nul 2>&1

reg add "HKCU\Software\Classes\http\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
reg add "HKCU\Software\Classes\https\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1

reg add "HKLM\SOFTWARE\Classes\Applications\msedge.exe\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
reg add "HKCU\Software\Classes\Applications\msedge.exe\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1

reg add "HKLM\SOFTWARE\Clients\StartMenuInternet\Microsoft Edge\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args%" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Clients\StartMenuInternet\Microsoft Edge\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args%" /f >nul 2>&1
reg add "HKCU\Software\Clients\StartMenuInternet\Microsoft Edge\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args%" /f >nul 2>&1

reg delete "HKLM\SOFTWARE\Classes\MSEdgePDF\shell\open\command" /v "DelegateExecute" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\MSEdgeHTM\shell\open\command" /v "DelegateExecute" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\MSEdgeMHT\shell\open\command" /v "DelegateExecute" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\Microsoft-Edge\shell\open\command" /v "DelegateExecute" /f >nul 2>&1
reg delete "HKCU\Software\Classes\MSEdgePDF\shell\open\command" /v "DelegateExecute" /f >nul 2>&1
reg delete "HKCU\Software\Classes\MSEdgeHTM\shell\open\command" /v "DelegateExecute" /f >nul 2>&1
reg delete "HKCU\Software\Classes\MSEdgeMHT\shell\open\command" /v "DelegateExecute" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Microsoft-Edge\shell\open\command" /v "DelegateExecute" /f >nul 2>&1
reg delete "HKCU\Software\Classes\http\shell\open\command" /v "DelegateExecute" /f >nul 2>&1
reg delete "HKCU\Software\Classes\https\shell\open\command" /v "DelegateExecute" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\Applications\msedge.exe\shell\open\command" /v "DelegateExecute" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Applications\msedge.exe\shell\open\command" /v "DelegateExecute" /f >nul 2>&1

set "temp_ps1=%temp%\edge_fix_temp.ps1"
echo $Arguments = '--disable-features=msFeatureGroupNewLookAndFeelHoldout --enable-features=msForceNoRoundedCornerAndMargin' > "%temp_ps1%"
echo $Shell = New-Object -ComObject WScript.Shell >> "%temp_ps1%"
echo $ShortcutPaths = @( >> "%temp_ps1%"
echo     "$env:Public\Desktop\Microsoft Edge.lnk", >> "%temp_ps1%"
echo     "$env:USERPROFILE\Desktop\Microsoft Edge.lnk", >> "%temp_ps1%"
echo     "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk", >> "%temp_ps1%"
echo     "$env:AppData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk", >> "%temp_ps1%"
echo     "$env:AppData\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk", >> "%temp_ps1%"
echo     "$env:AppData\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk" >> "%temp_ps1%"
echo ) >> "%temp_ps1%"
echo foreach ($Path in $ShortcutPaths) { >> "%temp_ps1%"
echo     if (Test-Path -LiteralPath $Path) { >> "%temp_ps1%"
echo         try { >> "%temp_ps1%"
echo             $Shortcut = $Shell.CreateShortcut($Path) >> "%temp_ps1%"
echo             if ($Shortcut.TargetPath -like "*msedge.exe*") { >> "%temp_ps1%"
echo                 $Shortcut.Arguments = $Arguments >> "%temp_ps1%"
echo                 $Shortcut.Save() >> "%temp_ps1%"
echo             } >> "%temp_ps1%"
echo         } catch {} >> "%temp_ps1%"
echo     } >> "%temp_ps1%"
echo } >> "%temp_ps1%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%temp_ps1%"
del "%temp_ps1%"

pause >nul
