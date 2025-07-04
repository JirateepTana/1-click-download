# PuTTY Installation Script
# This script checks if PuTTY is installed and installs it if not found

Write-Host "Checking for PuTTY installation..." -ForegroundColor Yellow

# Function to check if PuTTY is installed
function Test-PuTTYInstalled {
    # Check common installation paths
    $commonPaths = @(
        "${env:ProgramFiles}\PuTTY\putty.exe",
        "${env:ProgramFiles(x86)}\PuTTY\putty.exe",
        "${env:LOCALAPPDATA}\Programs\PuTTY\putty.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $true
        }
    }
    
    # Check if PuTTY is in PATH
    try {
        $null = Get-Command putty.exe -ErrorAction Stop
        return $true
    }
    catch {
        # PuTTY not found in PATH
    }
    
    # Check Windows Registry for PuTTY
    try {
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        $programs = Get-ItemProperty $regPath | Where-Object { $_.DisplayName -like "*PuTTY*" }
        if ($programs) {
            return $true
        }
    }
    catch {
        # Registry check failed
    }
    
    return $false
}

# Function to install PuTTY
function Install-PuTTY {
    Write-Host "PuTTY not found. Starting installation..." -ForegroundColor Green
    
    # Try winget first (Windows Package Manager)
    try {
        Write-Host "Trying winget installation..." -ForegroundColor Yellow
        $wingetResult = winget install PuTTY.PuTTY --silent --accept-source-agreements --accept-package-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "PuTTY installed successfully via winget!" -ForegroundColor Green
            
            # Add PuTTY to PATH if not already there
            $puttyPath = "${env:ProgramFiles}\PuTTY"
            if (Test-Path $puttyPath) {
                $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
                if ($currentPath -notlike "*$puttyPath*") {
                    Write-Host "Adding PuTTY to system PATH..." -ForegroundColor Yellow
                    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$puttyPath", "Machine")
                    Write-Host "PuTTY added to PATH. You may need to restart your terminal." -ForegroundColor Green
                }
            }
            return $true
        }
    }
    catch {
        Write-Host "winget installation failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Try chocolatey as backup
    try {
        Write-Host "Trying Chocolatey installation..." -ForegroundColor Yellow
        $chocoCheck = choco --version 2>$null
        if ($chocoCheck) {
            choco install putty -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "PuTTY installed successfully via Chocolatey!" -ForegroundColor Green
                return $true
            }
        }
        else {
            Write-Host "Chocolatey not found, skipping..." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Chocolatey installation failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Try direct download as last resort
    try {
        Write-Host "Trying direct download..." -ForegroundColor Yellow
        # Use a more reliable download URL
        $downloadUrl = "https://the.earth.li/~sgtatham/putty/0.81/w64/putty-64bit-0.81-installer.msi"
        $tempPath = "$env:TEMP\putty-installer.msi"
        
        # Use TLS 1.2 for secure connection
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -TimeoutSec 30
        
        if (Test-Path $tempPath) {
            Write-Host "Installing PuTTY..." -ForegroundColor Yellow
            
            # Install PuTTY silently
            $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$tempPath`" /quiet /norestart" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "PuTTY installed successfully!" -ForegroundColor Green
                
                # Clean up temporary file
                Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                
                # Add PuTTY to PATH if not already there
                $puttyPath = "${env:ProgramFiles}\PuTTY"
                if (Test-Path $puttyPath) {
                    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
                    if ($currentPath -notlike "*$puttyPath*") {
                        Write-Host "Adding PuTTY to system PATH..." -ForegroundColor Yellow
                        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$puttyPath", "Machine")
                        Write-Host "PuTTY added to PATH. You may need to restart your terminal." -ForegroundColor Green
                    }
                }
                
                return $true
            }
            else {
                Write-Host "PuTTY installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "Failed to download PuTTY installer" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error during direct download: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "All installation methods failed. Please install PuTTY manually from: https://www.putty.org/" -ForegroundColor Red
    return $false
}

# Function to verify installation
function Test-PuTTYInstallation {
    Write-Host "Verifying PuTTY installation..." -ForegroundColor Yellow
    
    if (Test-PuTTYInstalled) {
        # Try to get PuTTY version
        try {
            $puttyExe = Get-Command putty.exe -ErrorAction SilentlyContinue
            if ($puttyExe) {
                Write-Host "PuTTY is installed and available in PATH: $($puttyExe.Source)" -ForegroundColor Green
            }
            else {
                # Check common installation paths
                $commonPaths = @(
                    "${env:ProgramFiles}\PuTTY\putty.exe",
                    "${env:ProgramFiles(x86)}\PuTTY\putty.exe"
                )
                
                foreach ($path in $commonPaths) {
                    if (Test-Path $path) {
                        Write-Host "PuTTY is installed at: $path" -ForegroundColor Green
                        break
                    }
                }
            }
        }
        catch {
            Write-Host "PuTTY is installed but version check failed" -ForegroundColor Yellow
        }
        return $true
    }
    else {
        Write-Host "PuTTY installation verification failed" -ForegroundColor Red
        return $false
    }
}

# Main execution
try {
    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    
    if (-not $isAdmin) {
        Write-Host "Warning: Not running as administrator. Installation may fail." -ForegroundColor Yellow
    }
    
    # Check if PuTTY is already installed
    if (Test-PuTTYInstalled) {
        Write-Host "PuTTY is already installed on this system." -ForegroundColor Green
        Test-PuTTYInstallation
    }
    else {
        # Install PuTTY
        $installSuccess = Install-PuTTY
        
        if ($installSuccess) {
            # Verify installation
            Start-Sleep -Seconds 2
            if (Test-PuTTYInstallation) {
                Write-Host "PuTTY installation completed successfully!" -ForegroundColor Green
            }
            else {
                Write-Host "PuTTY installation may have failed. Please check manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Failed to install PuTTY. Please try manual installation." -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "PuTTY installation script completed." -ForegroundColor Cyan
