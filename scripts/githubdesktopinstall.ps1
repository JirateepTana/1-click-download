# GitHub Desktop Installation Script
# This script checks if GitHub Desktop is installed and installs it if not found

Write-Host "Checking for GitHub Desktop installation..." -ForegroundColor Yellow

# Function to check if GitHub Desktop is installed
function Test-GitHubDesktopInstalled {
    # Check common installation paths
    $commonPaths = @(
        "${env:LOCALAPPDATA}\GitHubDesktop\GitHubDesktop.exe",
        "${env:ProgramFiles}\GitHub Desktop\GitHubDesktop.exe",
        "${env:ProgramFiles(x86)}\GitHub Desktop\GitHubDesktop.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $true
        }
    }
    
    # Check if GitHub Desktop is in PATH
    try {
        $null = Get-Command GitHubDesktop.exe -ErrorAction Stop
        return $true
    }
    catch {
        # GitHub Desktop not found in PATH
    }
    
    # Check Windows Registry for GitHub Desktop
    try {
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($regPath in $regPaths) {
            $programs = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Where-Object { 
                $_.DisplayName -like "*GitHub Desktop*"
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

# Function to install GitHub Desktop
function Install-GitHubDesktop {
    Write-Host "GitHub Desktop not found. Starting installation..." -ForegroundColor Green
    
    # Try winget first (Windows Package Manager)
    try {
        Write-Host "Trying winget installation..." -ForegroundColor Yellow
        winget install GitHub.GitHubDesktop --silent --accept-source-agreements --accept-package-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "GitHub Desktop installed successfully via winget!" -ForegroundColor Green
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
            choco install github-desktop -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "GitHub Desktop installed successfully via Chocolatey!" -ForegroundColor Green
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
        
        # Get the latest GitHub Desktop release
        $apiUrl = "https://api.github.com/repos/desktop/desktop/releases/latest"
        $releaseInfo = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
        
        # Find the Windows installer
        $installer = $releaseInfo.assets | Where-Object { 
            $_.name -like "*Setup.exe" 
        } | Select-Object -First 1
        
        if ($installer) {
            $downloadUrl = $installer.browser_download_url
            $tempPath = "$env:TEMP\GitHubDesktopSetup.exe"
            
            Write-Host "Downloading GitHub Desktop installer: $($installer.name)" -ForegroundColor Yellow
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -TimeoutSec 60
            
            if (Test-Path $tempPath) {
                Write-Host "Installing GitHub Desktop..." -ForegroundColor Yellow
                
                # Install GitHub Desktop silently
                $process = Start-Process -FilePath $tempPath -ArgumentList "--silent" -Wait -PassThru
                
                if ($process.ExitCode -eq 0) {
                    Write-Host "GitHub Desktop installed successfully!" -ForegroundColor Green
                    Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                    return $true
                }
                else {
                    Write-Host "GitHub Desktop installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
                    return $false
                }
            }
            else {
                Write-Host "Failed to download GitHub Desktop installer" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "Could not find GitHub Desktop installer in the latest release" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error during direct download: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "All installation methods failed. Please install GitHub Desktop manually from: https://desktop.github.com/" -ForegroundColor Red
    return $false
}

# Function to verify installation
function Test-GitHubDesktopInstallation {
    Write-Host "Verifying GitHub Desktop installation..." -ForegroundColor Yellow
    
    if (Test-GitHubDesktopInstalled) {
        $gitHubDesktopPaths = @(
            "${env:LOCALAPPDATA}\GitHubDesktop\GitHubDesktop.exe",
            "${env:ProgramFiles}\GitHub Desktop\GitHubDesktop.exe",
            "${env:ProgramFiles(x86)}\GitHub Desktop\GitHubDesktop.exe"
        )
        
        foreach ($path in $gitHubDesktopPaths) {
            if (Test-Path $path) {
                Write-Host "GitHub Desktop is installed at: $path" -ForegroundColor Green
                
                # Try to get version information
                try {
                    $versionInfo = Get-ItemProperty $path | Select-Object -ExpandProperty VersionInfo
                    if ($versionInfo.ProductVersion) {
                        Write-Host "GitHub Desktop version: $($versionInfo.ProductVersion)" -ForegroundColor Green
                    }
                }
                catch {
                    Write-Host "GitHub Desktop version could not be determined" -ForegroundColor Yellow
                }
                
                return $true
            }
        }
        
        Write-Host "GitHub Desktop is installed but exact location could not be determined" -ForegroundColor Yellow
        return $true
    }
    else {
        Write-Host "GitHub Desktop installation verification failed" -ForegroundColor Red
        return $false
    }
}

# Function to check Git dependency
function Test-GitDependency {
    Write-Host "Checking Git dependency..." -ForegroundColor Yellow
    
    try {
        $gitVersion = git --version 2>$null
        if ($gitVersion -and $gitVersion -like "*git version*") {
            Write-Host "Git is installed: $gitVersion" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Git is not installed. GitHub Desktop works better with Git CLI." -ForegroundColor Yellow
            Write-Host "Consider installing Git first or run the gitinstall.ps1 script." -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "Git is not installed. GitHub Desktop works better with Git CLI." -ForegroundColor Yellow
        Write-Host "Consider installing Git first or run the gitinstall.ps1 script." -ForegroundColor Yellow
        return $false
    }
}

# Main execution
try {
    # Check Git dependency (optional for GitHub Desktop)
    $gitInstalled = Test-GitDependency
    if (-not $gitInstalled) {
        Write-Host "Note: Git is not installed. GitHub Desktop includes its own Git, but you may want to install Git CLI separately." -ForegroundColor Yellow
    }
    
    if (Test-GitHubDesktopInstalled) {
        Write-Host "GitHub Desktop is already installed on this system." -ForegroundColor Green
        Test-GitHubDesktopInstallation
    }
    else {
        $installSuccess = Install-GitHubDesktop
        
        if ($installSuccess) {
            Start-Sleep -Seconds 5
            if (Test-GitHubDesktopInstallation) {
                Write-Host "`nGitHub Desktop installation completed successfully!" -ForegroundColor Green
                Write-Host "You can now launch GitHub Desktop from the Start Menu or Desktop shortcut." -ForegroundColor Cyan
                Write-Host "Note: First launch will require GitHub account setup." -ForegroundColor Yellow
            }
            else {
                Write-Host "GitHub Desktop installation may have failed. Please check manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Failed to install GitHub Desktop. Please try manual installation." -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "GitHub Desktop installation script completed." -ForegroundColor Cyan
