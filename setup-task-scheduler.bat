@echo off
REM Setup Windows Task Scheduler for Auto-Pull CI/CD Pipeline
REM This script creates a scheduled task that runs every 6 minutes

echo Setting up Windows Task Scheduler for Auto-Pull...

REM Get the current directory
set "SCRIPT_DIR=%~dp0"
set "PS_SCRIPT=%SCRIPT_DIR%auto-pull.ps1"

echo Script directory: %SCRIPT_DIR%
echo PowerShell script: %PS_SCRIPT%

REM Check if PowerShell script exists
if not exist "%PS_SCRIPT%" (
    echo ERROR: PowerShell script not found at %PS_SCRIPT%
    pause
    exit /b 1
)

echo Creating scheduled task...

REM Create the scheduled task
schtasks /create /tn "GitAutoPull_CPIO" /tr "powershell.exe -ExecutionPolicy Bypass -File \"%PS_SCRIPT%\"" /sc minute /mo 6 /st 09:00 /ru "%USERNAME%" /rp /f

if %errorlevel% equ 0 (
    echo SUCCESS: Scheduled task 'GitAutoPull_CPIO' created successfully!
    echo Task will run every 6 minutes starting from 9:00 AM
    echo.
    echo To manage this task:
    echo - View: schtasks /query /tn "GitAutoPull_CPIO"
    echo - Start: schtasks /run /tn "GitAutoPull_CPIO"
    echo - Stop: schtasks /end /tn "GitAutoPull_CPIO"
    echo - Delete: schtasks /delete /tn "GitAutoPull_CPIO" /f
    echo.
    echo The task is now active and will begin pulling changes automatically.
) else (
    echo ERROR: Failed to create scheduled task
    echo Please run this batch file as Administrator
)

echo.
echo Press any key to continue...
pause >nul