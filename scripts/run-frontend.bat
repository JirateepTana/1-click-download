@echo off
REM Batch file to run the frontend PowerShell script with proper PowerShell context
echo Starting 1-Click Installer Frontend...

REM Check if PowerShell is available
where powershell.exe >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo Using Windows PowerShell...
    powershell.exe -NoLogo -ExecutionPolicy Bypass -File "%~dp0frontend.ps1"
) else (
    REM Try PowerShell Core
    where pwsh.exe >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo Using PowerShell Core...
        pwsh.exe -NoLogo -ExecutionPolicy Bypass -File "%~dp0frontend.ps1"
    ) else (
        REM Try full path to Windows PowerShell
        if exist "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" (
            echo Using Windows PowerShell ^(full path^)...
            "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -ExecutionPolicy Bypass -File "%~dp0frontend.ps1"
        ) else (
            echo ERROR: PowerShell not found on this system!
            echo Please install PowerShell or ensure it's in your PATH.
            pause
        )
    )
)
            echo ERROR: PowerShell not found on this system!
            echo Please install PowerShell or ensure it's in your PATH.
            pause
        )
    )
)

if %ERRORLEVEL% NEQ 0 (
    echo An error occurred while running the script.
    pause
)
