@echo off
chcp 65001 >nul
title Clean_Temp_SSD_v1.0 - by mhmad240
color 0B

REM ================================================
REM FIX FOR BAT TO EXE CONVERTER
REM ================================================

REM defines a temporary path to work correctly with EXE
cd /d "%~dp0"

REM ================================================
REM CUSTOM WELCOME SCREEN WITH INFO
REM ================================================
cls
echo ================================================
echo      Clean Temp SSD Tool
echo ================================================
echo Version: 1.0
echo Release Date: 26/02/2026
echo Created by: mhmad240
echo.
echo This tool will clean temporary files
echo and improve system performance
echo.
echo ================================================
echo Contact / Support:
echo Telegram: @mhmad240
echo ================================================
echo.
echo Welcome to Clean Temp SSD Tool
echo.
echo ================================================
echo.
echo Press any key to continue...
pause >nul

REM ================================================
REM CHECK ADMINISTRATOR PRIVILEGES
REM ================================================

REM Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo ================================================
    echo ERROR: This script must be run as Administrator
    echo ================================================
    echo.
    echo Please right-click and select "Run as Administrator"
    echo.
    echo Press any key to exit...
    pause >nul
    exit
)

cls
echo ================================================
echo [OK] Running with administrator privileges
echo ================================================
echo.

REM Calculate initial free space
echo Calculating initial free space...
for /f "tokens=2 delims==" %%a in ('wmic logicaldisk where DeviceID^="C:" get FreeSpace /value ^| find "="') do set FREE_BYTES=%%a
set /a INITIAL_FREE=%FREE_BYTES:~0,-9%
echo Initial free space on C: drive: %INITIAL_FREE% GB
echo.

echo Press any key to start cleanup...
pause >nul

cls
echo.
echo ================================================
echo STAGE 1: BASIC TEMPORARY FILES CLEANUP
echo ================================================
echo.

REM 1. Clean Windows Temp
echo [1/18] Cleaning Windows Temp folder...
if exist "C:\Windows\Temp" (
    del /q /f /s "C:\Windows\Temp\*.*" >nul 2>&1
    for /d %%p in ("C:\Windows\Temp\*.*") do rd /q /s "%%p" 2>nul
    echo [OK] Windows Temp cleaned
)

REM 2. Clean User Temp
echo [2/18] Cleaning User Temp folder...
if exist "%TEMP%" (
    del /q /f /s "%TEMP%\*.*" >nul 2>&1
    for /d %%p in ("%TEMP%\*.*") do rd /q /s "%%p" 2>nul
    echo [OK] User Temp cleaned
)

REM 3. Clean Prefetch
echo [3/18] Cleaning Prefetch folder...
if exist "C:\Windows\Prefetch" (
    del /q /f /s "C:\Windows\Prefetch\*.*" >nul 2>&1
    echo [OK] Prefetch cleaned
)

REM 4. Clean Windows Update Cache
echo [4/18] Cleaning Windows Update cache...
net stop wuauserv >nul 2>&1
if exist "C:\Windows\SoftwareDistribution\Download" (
    del /q /f /s "C:\Windows\SoftwareDistribution\Download\*.*" >nul 2>&1
    for /d %%p in ("C:\Windows\SoftwareDistribution\Download\*.*") do rd /q /s "%%p" 2>nul
    echo [OK] Windows Update cache cleaned
)
net start wuauserv >nul 2>&1

REM 5. Clean Internet Cache
echo [5/18] Cleaning Internet cache...
if exist "%USERPROFILE%\AppData\Local\Microsoft\Windows\INetCache" (
    del /q /f /s "%USERPROFILE%\AppData\Local\Microsoft\Windows\INetCache\*.*" >nul 2>&1
    echo [OK] Internet cache cleaned
)

REM 6. Clean .old files
echo [6/18] Cleaning .old files...
if exist "C:\Windows\System32\*.old" (
    del /q /f "C:\Windows\System32\*.old" >nul 2>&1
    echo [OK] .old files cleaned
)

REM 7. Handle Memory.dmp
echo [7/18] Checking Memory.dmp file...
if exist "C:\Windows\MEMORY.DMP" (
    del /q /f "C:\Windows\MEMORY.DMP" >nul 2>&1
    echo [OK] Memory.dmp deleted
) else echo [INFO] No memory dump file found

REM 8. Empty Recycle Bin
echo [8/18] Emptying Recycle Bin...
powershell.exe -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo [OK] Recycle Bin emptied

echo.
echo ================================================
echo STAGE 2: WINDOWS COMPONENT CLEANUP
echo ================================================
echo.

REM 9. DISM Component Cleanup
echo [9/18] Running DISM component cleanup...
echo [WAIT] This may take 15-30 minutes...
dism.exe /online /cleanup-image /startcomponentcleanup >nul 2>&1
echo [OK] DISM component cleanup completed

REM 10. DISM with Reset Base
echo [10/18] Running deep DISM cleanup with reset base...
echo [WAIT] This may take 30-60 minutes...
echo [NOTE] This prevents rolling back to older Windows versions
dism.exe /online /cleanup-image /startcomponentcleanup /resetbase >nul 2>&1
echo [OK] Deep DISM cleanup completed

REM 11. System File Checker
echo [11/18] Running System File Checker...
echo [WAIT] This may take 15-30 minutes...
sfc /scannow >nul 2>&1
echo [OK] System File Checker completed

echo.
echo ================================================
echo STAGE 3: ADDITIONAL SAFE CLEANUP
echo ================================================
echo.

REM 12. Clean Delivery Optimization
echo [12/18] Cleaning Delivery Optimization files...
if exist "C:\Windows\SoftwareDistribution\DeliveryOptimization" (
    del /q /f /s "C:\Windows\SoftwareDistribution\DeliveryOptimization\*.*" >nul 2>&1
    for /d %%p in ("C:\Windows\SoftwareDistribution\DeliveryOptimization\*.*") do rd /q /s "%%p" 2>nul
    echo [OK] Delivery Optimization cleaned
)

REM 13. Clean Windows Logs
echo [13/18] Cleaning Windows log files...
if exist "C:\Windows\Logs" (
    del /q /f /s "C:\Windows\Logs\*.*" >nul 2>&1
    for /d %%p in ("C:\Windows\Logs\*.*") do rd /q /s "%%p" 2>nul
)
if exist "C:\Windows\System32\LogFiles" (
    del /q /f /s "C:\Windows\System32\LogFiles\*.*" >nul 2>&1
    for /d %%p in ("C:\Windows\System32\LogFiles\*.*") do rd /q /s "%%p" 2>nul
)
echo [OK] Log files cleaned

REM 14. Clean Error Reporting
echo [14/18] Cleaning Windows Error Reporting files...
if exist "C:\ProgramData\Microsoft\Windows\WER" (
    del /q /f /s "C:\ProgramData\Microsoft\Windows\WER\*.*" >nul 2>&1
    for /d %%p in ("C:\ProgramData\Microsoft\Windows\WER\*.*") do rd /q /s "%%p" 2>nul
    echo [OK] Error Reporting cleaned
)

REM 15. Clean Font Cache
echo [15/18] Cleaning font cache...
net stop FontCache >nul 2>&1
if exist "%USERPROFILE%\AppData\Local\Microsoft\Windows\FontCache" (
    del /q /f /s "%USERPROFILE%\AppData\Local\Microsoft\Windows\FontCache\*.*" >nul 2>&1
    for /d %%p in ("%USERPROFILE%\AppData\Local\Microsoft\Windows\FontCache\*.*") do rd /q /s "%%p" 2>nul
)
net start FontCache >nul 2>&1
echo [OK] Font cache cleaned

REM 16. Clean Printer Spooler
echo [16/18] Cleaning printer spooler...
net stop Spooler >nul 2>&1
if exist "C:\Windows\System32\spool\PRINTERS" (
    del /q /f /s "C:\Windows\System32\spool\PRINTERS\*.*" >nul 2>&1
    for /d %%p in ("C:\Windows\System32\spool\PRINTERS\*.*") do rd /q /s "%%p" 2>nul
)
net start Spooler >nul 2>&1
echo [OK] Printer spooler cleaned

REM 17. Windows.old folder check
echo [17/18] Checking for Windows.old folder...
if exist "C:\Windows.old" (
    echo [FOUND] Windows.old folder detected
    choice /M "Delete Windows.old folder"
    if errorlevel 2 (
        echo [INFO] Windows.old folder kept
    ) else (
        takeown /F "C:\Windows.old" /R /D Y >nul 2>&1
        icacls "C:\Windows.old" /grant administrators:F /T >nul 2>&1
        rd /s /q "C:\Windows.old" 2>nul
        echo [OK] Windows.old folder deleted
    )
) else echo [INFO] No Windows.old folder found

REM 18. Restore Points
echo [18/18] Checking restore points...
choice /M "Delete ALL restore points"
if errorlevel 2 (
    echo [INFO] Restore points kept
) else (
    vssadmin delete shadows /for=c: /all /quiet >nul 2>&1
    echo [OK] All restore points deleted
)

echo.
echo ================================================
echo STAGE 4: FINAL SYSTEM CLEANUP
echo ================================================
echo.

REM Clear DNS cache
ipconfig /flushdns >nul 2>&1
echo [OK] DNS cache cleared

REM Clear thumbnail cache
del /q /f /s "%USERPROFILE%\AppData\Local\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
echo [OK] Thumbnail cache cleared

REM Disable Hibernation
powercfg -h off >nul 2>&1
echo [OK] Hibernation disabled

REM Clean browser caches
if exist "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Cache" (
    del /q /f /s "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Cache\*.*" >nul 2>&1
    echo [OK] Chrome cache cleaned
)
if exist "%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Default\Cache" (
    del /q /f /s "%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*.*" >nul 2>&1
    echo [OK] Edge cache cleaned
)

echo.
echo ================================================
echo CALCULATING SPACE SAVED...
echo ================================================
echo.

REM Calculate final free space
for /f "tokens=2 delims==" %%a in ('wmic logicaldisk where DeviceID^="C:" get FreeSpace /value ^| find "="') do set FREE_BYTES=%%a
set /a FINAL_FREE=%FREE_BYTES:~0,-9%
set /a FREED_SPACE=%FINAL_FREE% - %INITIAL_FREE%

echo.
echo ================================================
echo CLEANUP COMPLETED!
echo ================================================
echo Initial free space: %INITIAL_FREE% GB
echo Final free space:   %FINAL_FREE% GB
echo ------------------------------------------------
if %FREED_SPACE% GTR 0 (
    echo You freed up %FREED_SPACE% GB!
) else (
    echo No additional space freed
)
echo.
echo ================================================
echo Thank you for using Clean Temp SSD Tool v1.0
echo For support: Telegram @mhmad240
echo ================================================
echo.
echo Press any key to exit...
pause >nul
exit