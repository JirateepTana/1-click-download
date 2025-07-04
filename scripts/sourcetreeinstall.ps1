# SourceTree Installation Script
# This script checks if SourceTree is installed and installs it if not found

Write-Host "Checking for SourceTree installation..." -ForegroundColor Yellow

# Function to check if SourceTree is installed
function Test-SourceTreeInstalled {
    # Check common installation paths
    $commonPaths = @(
        "${env:LOCALAPPDATA}\SourceTree\SourceTree.exe",
        "${env:ProgramFiles}\Atlassian\SourceTree\SourceTree.exe",
        "${env:ProgramFiles(x86)}\Atlassian\SourceTree\SourceTree.exe",
        "${env:LOCALAPPDATA}\Atlassian\SourceTree\SourceTree.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $true
        }
    }
    
    # Check if SourceTree is in PATH
    try {
        $null = Get-Command SourceTree.exe -ErrorAction Stop
        return $true
    }
    catch {
        # SourceTree not found in PATH
    }
    
    # Check Windows Registry for SourceTree
    try {
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($regPath in $regPaths) {
            $programs = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Where-Object { 
                $_.DisplayName -like "*SourceTree*" -or $_.DisplayName -like "*Atlassian SourceTree*"
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

# Function to install SourceTree
function Install-SourceTree {
    Write-Host "SourceTree not found. Starting installation..." -ForegroundColor Green
    
    # Try winget first (Windows Package Manager)
    try {
        Write-Host "Trying winget installation..." -ForegroundColor Yellow
        winget install Atlassian.Sourcetree --silent --accept-source-agreements --accept-package-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "SourceTree installed successfully via winget!" -ForegroundColor Green
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
            choco install sourcetree -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "SourceTree installed successfully via Chocolatey!" -ForegroundColor Green
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
        # SourceTree's official download URL
        $downloadUrl = "https://product-downloads.atlassian.com/software/sourcetree/windows/ga/SourceTreeSetup-3.4.17.exe"
        $tempPath = "$env:TEMP\SourceTreeSetup.exe"
        
        Write-Host "Downloading SourceTree installer..." -ForegroundColor Yellow
        # Use TLS 1.2 for secure connection
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -TimeoutSec 60
        
        if (Test-Path $tempPath) {
            Write-Host "Installing SourceTree..." -ForegroundColor Yellow
            
            # Install SourceTree silently
            # SourceTree installer supports /S for silent installation
            $process = Start-Process -FilePath $tempPath -ArgumentList "/S" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "SourceTree installed successfully!" -ForegroundColor Green
                
                # Clean up temporary file
                Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                
                # Add SourceTree to PATH if not already there
                $sourceTreePaths = @(
                    "${env:LOCALAPPDATA}\SourceTree",
                    "${env:ProgramFiles}\Atlassian\SourceTree",
                    "${env:ProgramFiles(x86)}\Atlassian\SourceTree"
                )
                
                foreach ($sourceTreePath in $sourceTreePaths) {
                    if (Test-Path $sourceTreePath) {
                        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
                        if ($currentPath -notlike "*$sourceTreePath*") {
                            Write-Host "Adding SourceTree to system PATH..." -ForegroundColor Yellow
                            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$sourceTreePath", "Machine")
                            Write-Host "SourceTree added to PATH. You may need to restart your terminal." -ForegroundColor Green
                        }
                        break
                    }
                }
                
                return $true
            }
            else {
                Write-Host "SourceTree installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "Failed to download SourceTree installer" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error during direct download: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "All installation methods failed. Please install SourceTree manually from: https://www.sourcetreeapp.com/" -ForegroundColor Red
    return $false
}

# Function to verify installation and show SourceTree info
function Test-SourceTreeInstallation {
    Write-Host "Verifying SourceTree installation..." -ForegroundColor Yellow
    
    if (Test-SourceTreeInstalled) {
        # Try to find SourceTree executable
        $sourceTreePaths = @(
            "${env:LOCALAPPDATA}\SourceTree\SourceTree.exe",
            "${env:ProgramFiles}\Atlassian\SourceTree\SourceTree.exe",
            "${env:ProgramFiles(x86)}\Atlassian\SourceTree\SourceTree.exe",
            "${env:LOCALAPPDATA}\Atlassian\SourceTree\SourceTree.exe"
        )
        
        foreach ($path in $sourceTreePaths) {
            if (Test-Path $path) {
                Write-Host "SourceTree is installed at: $path" -ForegroundColor Green
                
                # Try to get version information
                try {
                    $versionInfo = Get-ItemProperty $path | Select-Object -ExpandProperty VersionInfo
                    if ($versionInfo.ProductVersion) {
                        Write-Host "SourceTree version: $($versionInfo.ProductVersion)" -ForegroundColor Green
                    }
                }
                catch {
                    Write-Host "SourceTree version could not be determined" -ForegroundColor Yellow
                }
                
                return $true
            }
        }
        
        Write-Host "SourceTree is installed but exact location could not be determined" -ForegroundColor Yellow
        return $true
    }
    else {
        Write-Host "SourceTree installation verification failed" -ForegroundColor Red
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
            Write-Host "Git is not installed. SourceTree requires Git to function properly." -ForegroundColor Yellow
            Write-Host "Please install Git first or run the gitinstall.ps1 script." -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Host "Git is not installed. SourceTree requires Git to function properly." -ForegroundColor Yellow
        Write-Host "Please install Git first or run the gitinstall.ps1 script." -ForegroundColor Yellow
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
    
    # Check Git dependency
    $gitInstalled = Test-GitDependency
    if (-not $gitInstalled) {
        Write-Host "Warning: Git is not installed. SourceTree may not function properly without Git." -ForegroundColor Yellow
        $continue = Read-Host "Do you want to continue with SourceTree installation anyway? (y/N)"
        if ($continue -notlike "y*") {
            Write-Host "Installation cancelled. Please install Git first." -ForegroundColor Yellow
            exit 0
        }
    }
    
    # Check if SourceTree is already installed
    if (Test-SourceTreeInstalled) {
        Write-Host "SourceTree is already installed on this system." -ForegroundColor Green
        Test-SourceTreeInstallation
    }
    else {
        # Install SourceTree
        $installSuccess = Install-SourceTree
        
        if ($installSuccess) {
            # Verify installation
            Start-Sleep -Seconds 5
            if (Test-SourceTreeInstallation) {
                Write-Host "`nSourceTree installation completed successfully!" -ForegroundColor Green
                Write-Host "You can now launch SourceTree from the Start Menu or Desktop shortcut." -ForegroundColor Cyan
                Write-Host "Note: First launch may require Atlassian account setup." -ForegroundColor Yellow
            }
            else {
                Write-Host "SourceTree installation may have failed. Please check manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Failed to install SourceTree. Please try manual installation." -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "SourceTree installation script completed." -ForegroundColor Cyan
