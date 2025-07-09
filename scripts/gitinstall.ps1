# Git Installation Script
# This script always installs or repairs Git for Windows, sets up recommended defaults,
# and configures Git to use Vim, Windows Secure Channel, and Windows-style checkout/Unix-style commit line endings.



Write-Host "Checking for Git installation or update..." -ForegroundColor Yellow

function Install-Git {
    # Download the latest Git for Windows installer from the official GitHub releases
    $apiUrl = "https://api.github.com/repos/git-for-windows/git/releases/latest"
    try {
        $releaseInfo = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
    }
    catch {
        Write-Host "Failed to fetch Git release info. Please check your internet connection." -ForegroundColor Red
        return $false
    }

    $installer = $releaseInfo.assets | Where-Object { $_.name -like "*64-bit.exe" -and $_.name -notlike "*MinGit*" } | Select-Object -First 1
    if (-not $installer) {
        Write-Host "Could not find a suitable Git installer in the latest release." -ForegroundColor Red
        return $false
    }

    $downloadUrl = $installer.browser_download_url
    $tempPath = "$env:TEMP\Git-Setup.exe"

    Write-Host "Downloading Git installer: $($installer.name)" -ForegroundColor Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -TimeoutSec 120
    }
    catch {
        Write-Host "Failed to download Git installer. Please check your internet connection." -ForegroundColor Red
        return $false
    }

    if (-not (Test-Path $tempPath)) {
        Write-Host "Failed to download Git installer." -ForegroundColor Red
        return $false
    }

    Write-Host "Installing Git..." -ForegroundColor Yellow

    # Silent install with desktop icon, context menu, and recommended defaults
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
        Remove-Item $tempPath -Force -ErrorAction SilentlyContinue

        # Add Git to PATH for current session and system
        $gitPath = "${env:ProgramFiles}\Git\bin"
        if (Test-Path $gitPath) {
            $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
            if ($currentPath -notlike "*$gitPath*") {
                Write-Host "Adding Git to system PATH..." -ForegroundColor Yellow
                [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$gitPath", "Machine")
                Write-Host "Git added to PATH. You may need to restart your terminal." -ForegroundColor Green
            }
            $env:PATH = "$env:PATH;$gitPath"
            Write-Host "Git added to current session PATH." -ForegroundColor Yellow
        }

        # Configure Git settings (now that git.exe is available)
        try {
            git config --global http.sslbackend schannel
            Write-Host "Set Git to use Windows Secure Channel (schannel) for SSL/TLS." -ForegroundColor Cyan
        }
        catch { Write-Host "Failed to set http.sslbackend schannel." -ForegroundColor Yellow }

        try {
            git config --global core.autocrlf true
            Write-Host "Set Git to checkout Windows-style, commit Unix-style line endings." -ForegroundColor Cyan
        }
        catch { Write-Host "Failed to set core.autocrlf." -ForegroundColor Yellow }

        $vimPath = "${env:ProgramFiles}\Git\usr\bin\vim.exe"
        if (Test-Path $vimPath) {
            try {
                git config --global core.editor "`"$vimPath`""
                Write-Host "Set Git core.editor to Vim." -ForegroundColor Cyan
            }
            catch { Write-Host "Failed to set core.editor to Vim." -ForegroundColor Yellow }
        }
        else {
            Write-Host "Vim not found in Git installation. Skipping core.editor setup." -ForegroundColor Yellow
        }

        return $true
    }
    else {
        Write-Host "Git installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
        return $false
    }
}

function Test-GitInstallation {
    Write-Host "Verifying Git installation..." -ForegroundColor Yellow
    try {
        $gitVersion = git --version 2>$null
        if ($gitVersion) {
            Write-Host "Git is installed: $gitVersion" -ForegroundColor Green
            $gitPath = Get-Command git.exe -ErrorAction SilentlyContinue
            if ($gitPath) {
                Write-Host "Git executable location: $($gitPath.Source)" -ForegroundColor Green
            }
            return $true
        }
    }
    catch {
        Write-Host "Git is installed but version check failed" -ForegroundColor Yellow
    }
    Write-Host "Git installation verification failed" -ForegroundColor Red
    return $false
}

# Main execution
try {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $isAdmin) {
        Write-Host "Warning: Not running as administrator. Installation may fail." -ForegroundColor Yellow
    }

    $installSuccess = Install-Git

    if ($installSuccess) {
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
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Git installation script completed." -ForegroundColor Cyan