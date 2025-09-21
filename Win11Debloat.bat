@echo off
title Windows 11 CPU & System Efficiency Tool v5.1
color 0a

:: Auto-elevate if not admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requires admin. Relaunching...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit
)

:: Log file
set "LogFile=%~dp0CPU_System_Efficiency_Log.txt"
echo ==== CPU & System Efficiency Tool v5.1 - %date% %time% ==== >> "%LogFile%"

:Menu
cls
echo ==================================================
echo       Windows 11 CPU & System Efficiency Tool v5.1
echo ==================================================
echo.
echo [1] Show Top CPU Processes
echo [2] Show Optional Services
echo [3] Show Startup Apps
echo [4] One-Click Auto Optimization
echo [0] Exit
echo ==================================================
echo.

set /p choice=Enter your choice: 

if /i "%choice%"=="1" (
    powershell -NoProfile -Command "Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 | Format-Table -AutoSize"
    echo [%date% %time%] Displayed top CPU processes >> "%LogFile%"
    pause
    goto Menu
)

if /i "%choice%"=="2" (
    powershell -NoProfile -Command "try { $s=Get-Service | Where-Object { $_.Name -match 'Xbox|PrintSpooler|Maps|OneSyncSvc' }; if ($s) { $s | Format-Table Status, Name, DisplayName -AutoSize } else { Write-Host 'No optional services found!' -ForegroundColor Red } } catch { Write-Host 'Failed to query services!' -ForegroundColor Red }"
    echo [%date% %time%] Queried optional services >> "%LogFile%"
    pause
    goto Menu
)

if /i "%choice%"=="3" (
    powershell -NoProfile -Command "try { $a=Get-CimInstance -ClassName Win32_StartupCommand; if ($a) { $a | Select-Object Name, Command, User | Format-Table -AutoSize } else { Write-Host 'No startup apps found!' -ForegroundColor Red } } catch { Write-Host 'Failed to query startup apps!' -ForegroundColor Red }"
    echo [%date% %time%] Queried startup apps >> "%LogFile%"
    pause
    goto Menu
)

if /i "%choice%"=="4" goto Option6
if /i "%choice%"=="0" exit

echo Invalid choice. Try again.
pause
goto Menu

:: =====================================
:: Option6: One-Click Auto Optimization
:: =====================================
:Option6
cls
echo Running full automated optimization...
echo.

:: Services to disable
set "ServicesList=XboxGipSvc XboxNetApiSvc OneSyncSvc MapsBroker XblAuthManager XblGameSave"
for %%S in (%ServicesList%) do (
    echo Disabling service %%S...
    powershell -NoProfile -Command "try { Stop-Service -Name '%%S' -ErrorAction SilentlyContinue; Set-Service -Name '%%S' -StartupType Manual; Add-Content -Path '%LogFile%' -Value ('[%date% %time%] Service %%S disabled ✅') } catch { Add-Content -Path '%LogFile%' -Value ('[%date% %time%] Failed to disable service %%S ⚠️') }"
)

:: Startup apps to disable (skip Discord, Steam, Epic)
set "StartupApps=MicrosoftEdgeAutoLaunch GoogleChromeAutoLaunch OneDrive Teams"
for %%A in (%StartupApps%) do (
    echo Disabling startup app %%A...
    powershell -NoProfile -Command "try { $s=Get-CimInstance -ClassName Win32_StartupCommand | Where-Object { $_.Name -eq '%%A' }; if ($s) { $s | Remove-CimInstance -ErrorAction SilentlyContinue; Add-Content -Path '%LogFile%' -Value ('[%date% %time%] Startup App %%A disabled ✅') } else { Add-Content -Path '%LogFile%' -Value ('[%date% %time%] Startup App %%A not found ❌') } } catch { Add-Content -Path '%LogFile%' -Value ('[%date% %time%] Failed to remove Startup App %%A ⚠️') }"
)

:: Clear TEMP cache
echo Clearing TEMP cache...
powershell -NoProfile -Command "try { Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue; Add-Content -Path '%LogFile%' -Value ('[%date% %time%] Cleared TEMP memory cache ✅') } catch { Add-Content -Path '%LogFile%' -Value ('[%date% %time%] Failed to clear TEMP cache ⚠️') }"

:: Set High Performance Power Plan
echo Setting High Performance Power Plan...
powershell -NoProfile -Command "try { powercfg /setactive SCHEME_MIN; Add-Content -Path '%LogFile%' -Value ('[%date% %time%] Power Plan set to High Performance ✅') } catch { Add-Content -Path '%LogFile%' -Value ('[%date% %time%] Failed to set Power Plan ⚠️') }"

echo.
echo Optimization complete! Check log at:
echo %LogFile%
pause
goto Menu
