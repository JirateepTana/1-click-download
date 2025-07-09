# Postman Installation Script
# This script checks if Postman is installed and installs it if not found

Write-Host "Checking for Postman installation..." -ForegroundColor Yellow

# Function to check if Postman is installed
function Test-PostmanInstalled {
    # Check common installation paths
    $commonPaths = @(
        "${env:LOCALAPPDATA}\Postman\Postman.exe",
        "${env:ProgramFiles}\Postman\Postman.exe",
        "${env:ProgramFiles(x86)}\Postman\Postman.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $true
        }
    }
    
    # Check if Postman is in PATH
    try {
        $null = Get-Command Postman.exe -ErrorAction Stop
        return $true
    }
    catch {
        # Postman not found in PATH
    }
    
    # Check Windows Registry for Postman
    try {
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($regPath in $regPaths) {
            $programs = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Where-Object { 
                $_.DisplayName -like "*Postman*"
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

# Function to install Postman
function Install-Postman {
    Write-Host "Postman not found. Starting installation..." -ForegroundColor Green
    
    # Try winget first (Windows Package Manager)
    try {
        Write-Host "Trying winget installation..." -ForegroundColor Yellow
        winget install Postman.Postman --silent --accept-source-agreements --accept-package-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Postman installed successfully via winget!" -ForegroundColor Green
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
            choco install postman -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Postman installed successfully via Chocolatey!" -ForegroundColor Green
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
        $downloadUrl = "https://dl.pstmn.io/download/latest/win64"
        $tempPath = "$env:TEMP\Postman-Setup.exe"
        
        Write-Host "Downloading Postman installer..." -ForegroundColor Yellow
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -TimeoutSec 60
        
        if (Test-Path $tempPath) {
            Write-Host "Installing Postman..." -ForegroundColor Yellow
            
            # Install Postman silently
            $process = Start-Process -FilePath $tempPath -ArgumentList "--silent" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "Postman installed successfully!" -ForegroundColor Green
                Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                return $true
            }
            else {
                Write-Host "Postman installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "Failed to download Postman installer" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error during direct download: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "All installation methods failed. Please install Postman manually from: https://www.postman.com/downloads/" -ForegroundColor Red
    return $false
}

# Function to verify installation
function Test-PostmanInstallation {
    Write-Host "Verifying Postman installation..." -ForegroundColor Yellow
    
    if (Test-PostmanInstalled) {
        $postmanPaths = @(
            "${env:LOCALAPPDATA}\Postman\Postman.exe",
            "${env:ProgramFiles}\Postman\Postman.exe",
            "${env:ProgramFiles(x86)}\Postman\Postman.exe"
        )
        
        foreach ($path in $postmanPaths) {
            if (Test-Path $path) {
                Write-Host "Postman is installed at: $path" -ForegroundColor Green
                return $true
            }
        }
        
        Write-Host "Postman is installed but exact location could not be determined" -ForegroundColor Yellow
        return $true
    }
    else {
        Write-Host "Postman installation verification failed" -ForegroundColor Red
        return $false
    }
}

# Main execution
try {
    if (Test-PostmanInstalled) {
        Write-Host "Postman is already installed on this system." -ForegroundColor Green
        Test-PostmanInstallation
    }
    else {
        $installSuccess = Install-Postman
        
        if ($installSuccess) {
            Start-Sleep -Seconds 3
            if (Test-PostmanInstallation) {
                Write-Host "`nPostman installation completed successfully!" -ForegroundColor Green
                Write-Host "You can now launch Postman from the Start Menu or Desktop shortcut." -ForegroundColor Cyan
            }
            else {
                Write-Host "Postman installation may have failed. Please check manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Failed to install Postman. Please try manual installation." -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Postman installation script completed." -ForegroundColor Cyan
