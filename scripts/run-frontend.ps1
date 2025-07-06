# PowerShell launcher script for the 1-Click Installer Frontend
# This ensures the GUI runs with proper PowerShell context

param(
    [switch]$Elevated
)

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin -and -not $Elevated) {
    Write-Host "Note: Some installations may require administrator privileges." -ForegroundColor Yellow
    Write-Host "If you encounter permission issues, run this script as administrator." -ForegroundColor Yellow
    Write-Host ""
}

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Set execution policy for current session
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

# Run the main frontend script
$frontendScript = Join-Path $scriptDir "frontend.ps1"

if (Test-Path $frontendScript) {
    Write-Host "Starting 1-Click Installer Frontend..." -ForegroundColor Green
    & $frontendScript
}
else {
    Write-Host "ERROR: frontend.ps1 not found in $scriptDir" -ForegroundColor Red
    Read-Host "Press Enter to exit"
}
