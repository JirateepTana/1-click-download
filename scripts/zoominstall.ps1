# Zoom Installation Script
# This script checks if Zoom is installed and installs it if not found

Write-Host "Checking for Zoom installation..." -ForegroundColor Yellow

# Function to check if Zoom is installed
function Test-ZoomInstalled {
    # Check common installation paths
    $commonPaths = @(
        "${env:ProgramFiles}\Zoom\bin\Zoom.exe",
        "${env:ProgramFiles(x86)}\Zoom\bin\Zoom.exe",
        "${env:APPDATA}\Zoom\bin\Zoom.exe",
        "${env:LOCALAPPDATA}\Zoom\bin\Zoom.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $true
        }
    }
    
    # Check if Zoom is in PATH
    try {
        $null = Get-Command Zoom.exe -ErrorAction Stop
        return $true
    }
    catch {
        # Zoom not found in PATH
    }
    
    # Check Windows Registry for Zoom
    try {
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($regPath in $regPaths) {
            $programs = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Where-Object { 
                $_.DisplayName -like "*Zoom*" -and $_.DisplayName -notlike "*Zoom Player*"
            }
            if ($programs) {
                return $true
            }
        }
    }
    catch {
        # Registry check failed
    }
    
    return $false
}

# Function to install Zoom
function Install-Zoom {
    Write-Host "Zoom not found. Starting installation..." -ForegroundColor Green
    
    # Try winget first (Windows Package Manager)
    try {
        Write-Host "Trying winget installation..." -ForegroundColor Yellow
        winget install Zoom.Zoom --silent --accept-source-agreements --accept-package-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Zoom installed successfully via winget!" -ForegroundColor Green
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
            choco install zoom -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Zoom installed successfully via Chocolatey!" -ForegroundColor Green
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
        $downloadUrl = "https://zoom.us/client/latest/ZoomInstaller.exe"
        $tempPath = "$env:TEMP\ZoomInstaller.exe"
        
        Write-Host "Downloading Zoom installer..." -ForegroundColor Yellow
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -TimeoutSec 60
        
        if (Test-Path $tempPath) {
            Write-Host "Installing Zoom..." -ForegroundColor Yellow
            
            # Install Zoom silently
            $process = Start-Process -FilePath $tempPath -ArgumentList "/silent" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "Zoom installed successfully!" -ForegroundColor Green
                Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                return $true
            }
            else {
                Write-Host "Zoom installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "Failed to download Zoom installer" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error during direct download: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "All installation methods failed. Please install Zoom manually from: https://zoom.us/download" -ForegroundColor Red
    return $false
}

# Function to verify installation
function Test-ZoomInstallation {
    Write-Host "Verifying Zoom installation..." -ForegroundColor Yellow
    
    if (Test-ZoomInstalled) {
        $zoomPaths = @(
            "${env:ProgramFiles}\Zoom\bin\Zoom.exe",
            "${env:ProgramFiles(x86)}\Zoom\bin\Zoom.exe",
            "${env:APPDATA}\Zoom\bin\Zoom.exe",
            "${env:LOCALAPPDATA}\Zoom\bin\Zoom.exe"
        )
        
        foreach ($path in $zoomPaths) {
            if (Test-Path $path) {
                Write-Host "Zoom is installed at: $path" -ForegroundColor Green
                return $true
            }
        }
        
        Write-Host "Zoom is installed but exact location could not be determined" -ForegroundColor Yellow
        return $true
    }
    else {
        Write-Host "Zoom installation verification failed" -ForegroundColor Red
        return $false
    }
}

# Main execution
try {
    if (Test-ZoomInstalled) {
        Write-Host "Zoom is already installed on this system." -ForegroundColor Green
        Test-ZoomInstallation
    }
    else {
        $installSuccess = Install-Zoom
        
        if ($installSuccess) {
            Start-Sleep -Seconds 3
            if (Test-ZoomInstallation) {
                Write-Host "`nZoom installation completed successfully!" -ForegroundColor Green
                Write-Host "You can now launch Zoom from the Start Menu or Desktop shortcut." -ForegroundColor Cyan
            }
            else {
                Write-Host "Zoom installation may have failed. Please check manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Failed to install Zoom. Please try manual installation." -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Zoom installation script completed." -ForegroundColor Cyan
