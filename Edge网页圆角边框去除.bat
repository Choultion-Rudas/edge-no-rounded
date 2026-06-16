@echo off
:: 1. 设置控制台编码为 UTF-8 防止中文乱码
chcp 65001 >nul

:: 2. 自动获取管理员权限
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c ""%~s0"" ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

:: 3. 提权后的新窗口重置 UTF-8 编码
chcp 65001 >nul

echo ==============================================================
echo           正在执行新电脑一键 Edge 屏蔽圆角白边脚本
echo ==============================================================

:: 1. 动态获取系统中 Edge 的实际安装路径
set "EdgeExe="
for /f "tokens=2,*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe" /ve 2^>nul ^| findstr /i "REG_SZ"') do set "EdgeExe=%%j"

:: 如果获取失败，使用默认路径兜底
if not defined EdgeExe set "EdgeExe=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

:: 去掉路径两端的双引号
set "EdgeExe=%EdgeExe:"=%"

echo [1/3] 已定位 Edge 安装路径: "%EdgeExe%"
set "Args=--disable-features=msFeatureGroupNewLookAndFeelHoldout --enable-features=msForceNoRoundedCornerAndMargin"

echo [2/3] 正在安全写入文件协议与关联注册表...

:: A. 对于 Edge 专属的关联协议，我们无条件安全写入参数
reg add "HKLM\SOFTWARE\Classes\MSEdgePDF\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\MSEdgeHTM\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Classes\Microsoft-Edge\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% -- \"%%1\"" /f >nul 2>&1

reg add "HKCU\Software\Classes\MSEdgePDF\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
reg add "HKCU\Software\Classes\MSEdgeHTM\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
reg add "HKCU\Software\Classes\Microsoft-Edge\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% -- \"%%1\"" /f >nul 2>&1

:: B. 对于 http/https 通用网页协议，先查询当前是否属于 Edge，如果是才修改，防止误碰其他浏览器
for %%P in (http https) do (
    reg query "HKLM\SOFTWARE\Classes\%%P\shell\open\command" /ve 2>nul | findstr /i "msedge.exe" >nul && (
        reg add "HKLM\SOFTWARE\Classes\%%P\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
    )
    reg query "HKCU\Software\Classes\%%P\shell\open\command" /ve 2>nul | findstr /i "msedge.exe" >nul && (
        reg add "HKCU\Software\Classes\%%P\shell\open\command" /ve /t REG_SZ /d "\"%EdgeExe%\" %Args% --single-argument %%1" /f >nul 2>&1
    )
)

echo [3/3] 正在调用后台组件重构系统内所有快捷方式...
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

echo.
echo ==============================================================
echo 恭喜，全新系统一键修复与优化已全部完成！
echo.
echo *必看贴士*：
echo 1. 请在 Edge 浏览器设置的「开始、主页和新建标签页」中，
echo    将“Edge 启动时”修改为“打开以下页面”，并保持网址列表为空，
echo    这可以彻底防止双击 PDF 时多开一个空白的新建标签页。
echo.
echo 2. 别忘了在设置里关闭 Edge 的“启动增强”和“后台运行”，
echo    并确保在任务管理器里结束掉旧的 Edge 后台进程。
echo ==============================================================
echo 按任意键退出...
pause >nul