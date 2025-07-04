# Discord Installation Script
# This script checks if Discord is installed and installs it if not found

Write-Host "Checking for Discord installation..." -ForegroundColor Yellow

# Function to check if Discord is installed
function Test-DiscordInstalled {
    # Check common installation paths
    $commonPaths = @(
        "${env:LOCALAPPDATA}\Discord\Update.exe",
        "${env:LOCALAPPDATA}\Discord\app-*\Discord.exe",
        "${env:APPDATA}\Discord\Update.exe",
        "${env:ProgramFiles}\Discord\Discord.exe",
        "${env:ProgramFiles(x86)}\Discord\Discord.exe"
    )
    
    foreach ($path in $commonPaths) {
        if ($path -like "*app-*") {
            # Handle wildcard path for Discord app versions
            $parentPath = Split-Path $path -Parent
            if (Test-Path $parentPath) {
                $appFolders = Get-ChildItem $parentPath -Directory -Name "app-*" -ErrorAction SilentlyContinue
                if ($appFolders) {
                    foreach ($folder in $appFolders) {
                        $discordExe = Join-Path $parentPath "$folder\Discord.exe"
                        if (Test-Path $discordExe) {
                            return $true
                        }
                    }
                }
            }
        }
        else {
            if (Test-Path $path) {
                return $true
            }
        }
    }
    
    # Check if Discord is in PATH
    try {
        $null = Get-Command Discord.exe -ErrorAction Stop
        return $true
    }
    catch {
        # Discord not found in PATH
    }
    
    # Check Windows Registry for Discord
    try {
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($regPath in $regPaths) {
            $programs = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*Discord*" }
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

# Function to install Discord
function Install-Discord {
    Write-Host "Discord not found. Starting installation..." -ForegroundColor Green
    
    # Try winget first (Windows Package Manager)
    try {
        Write-Host "Trying winget installation..." -ForegroundColor Yellow
        winget install Discord.Discord --silent --accept-source-agreements --accept-package-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Discord installed successfully via winget!" -ForegroundColor Green
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
            choco install discord -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Discord installed successfully via Chocolatey!" -ForegroundColor Green
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
        # Discord's official download URL
        $downloadUrl = "https://discord.com/api/downloads/distributions/app/installers/latest?channel=stable&platform=win&arch=x64"
        $tempPath = "$env:TEMP\DiscordSetup.exe"
        
        # Use TLS 1.2 for secure connection
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -TimeoutSec 30
        
        if (Test-Path $tempPath) {
            Write-Host "Installing Discord..." -ForegroundColor Yellow
            
            # Install Discord silently
            $process = Start-Process -FilePath $tempPath -ArgumentList "--silent" -Wait -PassThru
            
            if ($process.ExitCode -eq 0) {
                Write-Host "Discord installed successfully!" -ForegroundColor Green
                
                # Clean up temporary file
                Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
                return $true
            }
            else {
                Write-Host "Discord installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
                return $false
            }
        }
        else {
            Write-Host "Failed to download Discord installer" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error during direct download: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host "All installation methods failed. Please install Discord manually from: https://discord.com/download" -ForegroundColor Red
    return $false
}

# Function to verify installation
function Test-DiscordInstallation {
    Write-Host "Verifying Discord installation..." -ForegroundColor Yellow
    
    if (Test-DiscordInstalled) {
        # Try to find Discord executable
        $discordPaths = @(
            "${env:LOCALAPPDATA}\Discord\app-*\Discord.exe",
            "${env:APPDATA}\Discord\app-*\Discord.exe",
            "${env:ProgramFiles}\Discord\Discord.exe",
            "${env:ProgramFiles(x86)}\Discord\Discord.exe"
        )
        
        foreach ($path in $discordPaths) {
            if ($path -like "*app-*") {
                # Handle wildcard path for Discord app versions
                $parentPath = Split-Path $path -Parent
                if (Test-Path $parentPath) {
                    $appFolders = Get-ChildItem $parentPath -Directory -Name "app-*" -ErrorAction SilentlyContinue
                    if ($appFolders) {
                        $latestApp = $appFolders | Sort-Object { [version]($_ -replace 'app-', '') } | Select-Object -Last 1
                        $discordExe = Join-Path $parentPath "$latestApp\Discord.exe"
                        if (Test-Path $discordExe) {
                            Write-Host "Discord is installed at: $discordExe" -ForegroundColor Green
                            return $true
                        }
                    }
                }
            }
            else {
                if (Test-Path $path) {
                    Write-Host "Discord is installed at: $path" -ForegroundColor Green
                    return $true
                }
            }
        }
        
        Write-Host "Discord is installed but exact location could not be determined" -ForegroundColor Yellow
        return $true
    }
    else {
        Write-Host "Discord installation verification failed" -ForegroundColor Red
        return $false
    }
}

# Main execution
try {
    # Check if Discord is already installed
    if (Test-DiscordInstalled) {
        Write-Host "Discord is already installed on this system." -ForegroundColor Green
        Test-DiscordInstallation
    }
    else {
        # Install Discord
        $installSuccess = Install-Discord
        
        if ($installSuccess) {
            # Verify installation
            Start-Sleep -Seconds 3
            if (Test-DiscordInstallation) {
                Write-Host "Discord installation completed successfully!" -ForegroundColor Green
                Write-Host "You can now launch Discord from the Start Menu or Desktop shortcut." -ForegroundColor Cyan
            }
            else {
                Write-Host "Discord installation may have failed. Please check manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Failed to install Discord. Please try manual installation." -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Discord installation script completed." -ForegroundColor Cyan
