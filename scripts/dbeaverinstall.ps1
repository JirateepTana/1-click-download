# DBeaver Installation Script
# This script checks if DBeaver is installed and installs it if not found

Write-Host "Checking for DBeaver installation..." -ForegroundColor Yellow

# Function to check if DBeaver is installed
function Test-DBeaverInstalled {
    # Check common installation paths
    $commonPaths = @(
        "${env:ProgramFiles}\DBeaver\dbeaver.exe",
        "${env:ProgramFiles(x86)}\DBeaver\dbeaver.exe",
        "${env:LOCALAPPDATA}\DBeaver\dbeaver.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $true
        }
    }
    
    # Check if DBeaver is in PATH
    try {
        $null = Get-Command dbeaver.exe -ErrorAction Stop
        return $true
    }
    catch {
        # DBeaver not found in PATH
    }
    
    # Check Windows Registry for DBeaver
    try {
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($regPath in $regPaths) {
            $programs = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Where-Object { 
                $_.DisplayName -like "*DBeaver*"
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

# Function to install DBeaver
function Install-DBeaver {
    Write-Host "DBeaver not found. Starting installation..." -ForegroundColor Green
    
    # Try winget first (Windows Package Manager)
    try {
        Write-Host "Trying winget installation..." -ForegroundColor Yellow
        winget install dbeaver.dbeaver --silent --accept-source-agreements --accept-package-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "DBeaver installed successfully via winget!" -ForegroundColor Green
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
            choco install dbeaver -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "DBeaver installed successfully via Chocolatey!" -ForegroundColor Green
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
        $downloadUrl = "https://dbeaver.io/files/dbeaver-ce-latest-x86_64-setup.exe"
        $tempPath = "$env:TEMP\DBeaver-Setup.exe"
        
        Write-Host "Downloading DBeaver installer..." -ForegroundColor Yellow
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -TimeoutSec 60
        
        if (Test-Path $tempPath) {
            Write-Host "Installing DBeaver..." -ForegroundColor Yellow
            
            # Install DBeaver silently
            $process = Start-Process -FilePath $tempPath -ArgumentList "/S" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "DBeaver installed successfully!" -ForegroundColor Green
                Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                return $true
            }
            else {
                Write-Host "DBeaver installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "Failed to download DBeaver installer" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error during direct download: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "All installation methods failed. Please install DBeaver manually from: https://dbeaver.io/download/" -ForegroundColor Red
    return $false
}

# Function to verify installation
function Test-DBeaverInstallation {
    Write-Host "Verifying DBeaver installation..." -ForegroundColor Yellow
    
    if (Test-DBeaverInstalled) {
        $dbeaverPaths = @(
            "${env:ProgramFiles}\DBeaver\dbeaver.exe",
            "${env:ProgramFiles(x86)}\DBeaver\dbeaver.exe",
            "${env:LOCALAPPDATA}\DBeaver\dbeaver.exe"
        )
        
        foreach ($path in $dbeaverPaths) {
            if (Test-Path $path) {
                Write-Host "DBeaver is installed at: $path" -ForegroundColor Green
                return $true
            }
        }
        
        Write-Host "DBeaver is installed but exact location could not be determined" -ForegroundColor Yellow
        return $true
    }
    else {
        Write-Host "DBeaver installation verification failed" -ForegroundColor Red
        return $false
    }
}

# Main execution
try {
    if (Test-DBeaverInstalled) {
        Write-Host "DBeaver is already installed on this system." -ForegroundColor Green
        Test-DBeaverInstallation
    }
    else {
        $installSuccess = Install-DBeaver
        
        if ($installSuccess) {
            Start-Sleep -Seconds 3
            if (Test-DBeaverInstallation) {
                Write-Host "`nDBeaver installation completed successfully!" -ForegroundColor Green
                Write-Host "You can now launch DBeaver from the Start Menu or Desktop shortcut." -ForegroundColor Cyan
            }
            else {
                Write-Host "DBeaver installation may have failed. Please check manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Failed to install DBeaver. Please try manual installation." -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "DBeaver installation script completed." -ForegroundColor Cyan
