# NVM (Node Version Manager) Installation Script
# This script checks if NVM is installed and installs it if not found

Write-Host "Checking for NVM installation..." -ForegroundColor Yellow

# Function to check if NVM is installed
function Test-NVMInstalled {
    # Check if NVM is in PATH
    try {
        $nvmVersion = nvm version 2>$null
        if ($nvmVersion) {
            return $true
        }
    }
    catch {
        # NVM not found in PATH
    }
    
    # Check common installation paths
    $commonPaths = @(
        "${env:ProgramFiles}\nodejs\nvm.exe",
        "${env:ProgramFiles(x86)}\nodejs\nvm.exe",
        "${env:APPDATA}\nvm\nvm.exe",
        "${env:LOCALAPPDATA}\nvm\nvm.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $true
        }
    }
    
    # Check Windows Registry for NVM
    try {
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($regPath in $regPaths) {
            $programs = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Where-Object { 
                $_.DisplayName -like "*NVM*" -or $_.DisplayName -like "*Node Version Manager*"
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

# Function to install NVM
function Install-NVM {
    Write-Host "NVM not found. Starting installation..." -ForegroundColor Green
    
    # Try chocolatey first
    try {
        Write-Host "Trying Chocolatey installation..." -ForegroundColor Yellow
        $chocoCheck = choco --version 2>$null
        if ($chocoCheck) {
            choco install nvm -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "NVM installed successfully via Chocolatey!" -ForegroundColor Green
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
    
    # Try direct download from GitHub
    try {
        Write-Host "Trying direct download from GitHub..." -ForegroundColor Yellow
        
        # Get the latest NVM for Windows release
        $apiUrl = "https://api.github.com/repos/coreybutler/nvm-windows/releases/latest"
        $releaseInfo = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
        
        # Find the installer
        $installer = $releaseInfo.assets | Where-Object { 
            $_.name -like "*setup.exe" 
        } | Select-Object -First 1
        
        if ($installer) {
            $downloadUrl = $installer.browser_download_url
            $tempPath = "$env:TEMP\nvm-setup.exe"
            
            Write-Host "Downloading NVM installer: $($installer.name)" -ForegroundColor Yellow
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -TimeoutSec 60
            
            if (Test-Path $tempPath) {
                Write-Host "Installing NVM..." -ForegroundColor Yellow
                
                # Install NVM silently
                $process = Start-Process -FilePath $tempPath -ArgumentList "/SILENT" -Wait -PassThru
                
                if ($process.ExitCode -eq 0) {
                    Write-Host "NVM installed successfully!" -ForegroundColor Green
                    Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                    
                    # Add NVM to PATH if not already there
                    $nvmPath = "${env:ProgramFiles}\nodejs"
                    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
                    if ($currentPath -notlike "*$nvmPath*") {
                        Write-Host "Adding NVM to system PATH..." -ForegroundColor Yellow
                        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$nvmPath", "Machine")
                        Write-Host "NVM added to PATH. You may need to restart your terminal." -ForegroundColor Green
                    }
                    
                    return $true
                }
                else {
                    Write-Host "NVM installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
                    return $false
                }
            }
            else {
                Write-Host "Failed to download NVM installer" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "Could not find NVM installer in the latest release" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error during direct download: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "All installation methods failed. Please install NVM manually from: https://github.com/coreybutler/nvm-windows" -ForegroundColor Red
    return $false
}

# Function to verify installation
function Test-NVMInstallation {
    Write-Host "Verifying NVM installation..." -ForegroundColor Yellow
    
    if (Test-NVMInstalled) {
        try {
            # Get NVM version
            $nvmVersion = nvm version 2>$null
            if ($nvmVersion) {
                Write-Host "NVM is installed: $nvmVersion" -ForegroundColor Green
            }
            
            # List installed Node.js versions
            $nvmList = nvm list 2>$null
            if ($nvmList) {
                Write-Host "Installed Node.js versions:" -ForegroundColor Green
                Write-Host $nvmList -ForegroundColor Cyan
            }
            
            return $true
        }
        catch {
            Write-Host "NVM is installed but version check failed" -ForegroundColor Yellow
            return $true
        }
    }
    else {
        Write-Host "NVM installation verification failed" -ForegroundColor Red
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
    
    if (Test-NVMInstalled) {
        Write-Host "NVM is already installed on this system." -ForegroundColor Green
        Test-NVMInstallation
    }
    else {
        $installSuccess = Install-NVM
        
        if ($installSuccess) {
            Start-Sleep -Seconds 3
            Write-Host "`nRefreshing environment variables..." -ForegroundColor Yellow
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
            
            if (Test-NVMInstallation) {
                Write-Host "`nNVM installation completed successfully!" -ForegroundColor Green
                Write-Host "You can now install Node.js versions using: nvm install 18.17.0" -ForegroundColor Cyan
                Write-Host "And switch between versions using: nvm use 18.17.0" -ForegroundColor Cyan
            }
            else {
                Write-Host "NVM installation may have failed. Please check manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Failed to install NVM. Please try manual installation." -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "NVM installation script completed." -ForegroundColor Cyan
