# Git Installation Script
# This script checks if Git is installed and installs it if not found

Write-Host "Checking for Git installation..." -ForegroundColor Yellow

# Function to check if Git is installed
function Test-GitInstalled {
    # Check if Git is in PATH
    try {
        $gitVersion = git --version 2>$null
        if ($gitVersion -and $gitVersion -like "*git version*") {
            return $true
        }
    }
    catch {
        # Git not found in PATH
    }
    
    # Check common installation paths
    $commonPaths = @(
        "${env:ProgramFiles}\Git\bin\git.exe",
        "${env:ProgramFiles(x86)}\Git\bin\git.exe",
        "${env:LOCALAPPDATA}\Programs\Git\bin\git.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $true
        }
    }
    
    # Check Windows Registry for Git
    try {
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($regPath in $regPaths) {
            $programs = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Where-Object { 
                $_.DisplayName -like "*Git*" -and $_.DisplayName -notlike "*GitHub*" 
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

# Function to install Git
function Install-Git {
    Write-Host "Git not found. Starting installation..." -ForegroundColor Green
    
    # Try winget first (Windows Package Manager)
    try {
        Write-Host "Trying winget installation..." -ForegroundColor Yellow
        winget install Git.Git --silent --accept-source-agreements --accept-package-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Git installed successfully via winget!" -ForegroundColor Green
            
            # Add Git to PATH if not already there
            $gitPath = "${env:ProgramFiles}\Git\bin"
            if (Test-Path $gitPath) {
                $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
                if ($currentPath -notlike "*$gitPath*") {
                    Write-Host "Adding Git to system PATH..." -ForegroundColor Yellow
                    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$gitPath", "Machine")
                    Write-Host "Git added to PATH. You may need to restart your terminal." -ForegroundColor Green
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
            choco install git -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Git installed successfully via Chocolatey!" -ForegroundColor Green
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
        # Get the latest Git release from GitHub API
        $apiUrl = "https://api.github.com/repos/git-for-windows/git/releases/latest"
        $releaseInfo = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
        
        # Find the 64-bit installer
        $installer = $releaseInfo.assets | Where-Object { 
            $_.name -like "*64-bit.exe" -and $_.name -notlike "*MinGit*" 
        } | Select-Object -First 1
        
        if ($installer) {
            $downloadUrl = $installer.browser_download_url
            $tempPath = "$env:TEMP\Git-Setup.exe"
            
            Write-Host "Downloading Git installer: $($installer.name)" -ForegroundColor Yellow
            # Use TLS 1.2 for secure connection
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -TimeoutSec 60
            
            if (Test-Path $tempPath) {
                Write-Host "Installing Git..." -ForegroundColor Yellow
                
                # Install Git silently with recommended settings
                $arguments = @(
                    "/VERYSILENT",
                    "/NORESTART",
                    "/NOCANCEL",
                    "/SP-",
                    "/CLOSEAPPLICATIONS",
                    "/RESTARTAPPLICATIONS",
                    "/COMPONENTS=`"icons,ext\reg\shellhere,assoc,assoc_sh`"",
                    "/TASKS=`"desktopicon,quicklaunchicon,addcontextmenufiles,addcontextmenufolders,associateshfiles`""
                )
                
                $process = Start-Process -FilePath $tempPath -ArgumentList $arguments -Wait -PassThru
                
                if ($process.ExitCode -eq 0) {
                    Write-Host "Git installed successfully!" -ForegroundColor Green
                    
                    # Clean up temporary file
                    Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                    
                    # Add Git to PATH if not already there
                    $gitPath = "${env:ProgramFiles}\Git\bin"
                    if (Test-Path $gitPath) {
                        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
                        if ($currentPath -notlike "*$gitPath*") {
                            Write-Host "Adding Git to system PATH..." -ForegroundColor Yellow
                            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$gitPath", "Machine")
                            Write-Host "Git added to PATH. You may need to restart your terminal." -ForegroundColor Green
                        }
                    }
                    return $true
                }
                else {
                    Write-Host "Git installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
                    return $false
                }
            }
            else {
                Write-Host "Failed to download Git installer" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "Could not find Git installer in the latest release" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error during direct download: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "All installation methods failed. Please install Git manually from: https://git-scm.com/download/windows" -ForegroundColor Red
    return $false
}

# Function to verify installation and show Git info
function Test-GitInstallation {
    Write-Host "Verifying Git installation..." -ForegroundColor Yellow
    
    if (Test-GitInstalled) {
        try {
            # Get Git version
            $gitVersion = git --version 2>$null
            if ($gitVersion) {
                Write-Host "Git is installed: $gitVersion" -ForegroundColor Green
            }
            
            # Get Git installation path
            $gitPath = Get-Command git.exe -ErrorAction SilentlyContinue
            if ($gitPath) {
                Write-Host "Git executable location: $($gitPath.Source)" -ForegroundColor Green
            }
            
            # Check Git configuration
            $userName = git config --global user.name 2>$null
            $userEmail = git config --global user.email 2>$null
            
            if (-not $userName -or -not $userEmail) {
                Write-Host "`nGit is installed but not configured. You may want to set up your identity:" -ForegroundColor Yellow
                Write-Host "  git config --global user.name `"Your Name`"" -ForegroundColor Cyan
                Write-Host "  git config --global user.email `"your.email@example.com`"" -ForegroundColor Cyan
            }
            else {
                Write-Host "Git is configured for user: $userName <$userEmail>" -ForegroundColor Green
            }
            
        }
        catch {
            Write-Host "Git is installed but version check failed" -ForegroundColor Yellow
        }
        return $true
    }
    else {
        Write-Host "Git installation verification failed" -ForegroundColor Red
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
    
    # Check if Git is already installed
    if (Test-GitInstalled) {
        Write-Host "Git is already installed on this system." -ForegroundColor Green
        Test-GitInstallation
    }
    else {
        # Install Git
        $installSuccess = Install-Git
        
        if ($installSuccess) {
            # Verify installation
            Start-Sleep -Seconds 3
            Write-Host "`nRefreshing environment variables..." -ForegroundColor Yellow
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
            
            if (Test-GitInstallation) {
                Write-Host "`nGit installation completed successfully!" -ForegroundColor Green
                Write-Host "You can now use Git from the command line." -ForegroundColor Cyan
            }
            else {
                Write-Host "Git installation may have failed. Please check manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Failed to install Git. Please try manual installation." -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Git installation script completed." -ForegroundColor Cyan
