# Zoom Complete Uninstall Script
# This script completely removes Zoom from the system including all user data and settings

Write-Host "Starting complete Zoom uninstall process..." -ForegroundColor Yellow
Write-Host "WARNING: This will remove ALL Zoom data including recordings, settings, and chat history!" -ForegroundColor Red

# Function to check if running as administrator
function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to force kill Zoom processes
function Stop-ZoomProcesses {
    Write-Host "Stopping Zoom processes..." -ForegroundColor Yellow
    
    $processes = @("Zoom", "ZoomLauncher", "ZoomWebHelper", "ZoomOpener", "CptHost", "RoomConnector", "airhost", "zTscoder", "zzhost", "zzplugin", "zCrashReport")
    foreach ($processName in $processes) {
        try {
            $runningProcesses = Get-Process -Name $processName -ErrorAction SilentlyContinue
            if ($runningProcesses) {
                Write-Host "Stopping $processName processes..." -ForegroundColor Yellow
                Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 1
            }
        }
        catch {
            # Process not running
        }
    }
    
    # Extra wait to ensure processes are terminated
    Start-Sleep -Seconds 3
}

# Function to uninstall via Windows Programs and Features
function Uninstall-ZoomFromRegistry {
    Write-Host "Attempting to uninstall Zoom via Windows uninstaller..." -ForegroundColor Yellow
    
    try {
        # Check both HKLM and HKCU uninstall keys
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($regPath in $regPaths) {
            $programs = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Where-Object { 
                $_.DisplayName -like "*Zoom*" -and $_.DisplayName -notlike "*Zoom Player*"
            }
            
            foreach ($program in $programs) {
                if ($program.UninstallString) {
                    Write-Host "Found Zoom uninstaller: $($program.DisplayName)" -ForegroundColor Green
                    
                    # Extract the uninstall command
                    $uninstallCmd = $program.UninstallString
                    
                    # Handle different uninstall string formats
                    if ($uninstallCmd -match '"([^"]+)"') {
                        $uninstallPath = $matches[1]
                        $arguments = $uninstallCmd.Replace("`"$uninstallPath`"", "").Trim()
                        
                        # Add silent flags for Zoom
                        if ($arguments) {
                            $arguments += " /uninstall /quiet"
                        }
                        else {
                            $arguments = "/uninstall /quiet"
                        }
                        
                        Write-Host "Running uninstaller: $uninstallPath $arguments" -ForegroundColor Yellow
                        $process = Start-Process -FilePath $uninstallPath -ArgumentList $arguments -Wait -PassThru -ErrorAction SilentlyContinue
                        
                        if ($process.ExitCode -eq 0) {
                            Write-Host "Zoom uninstalled successfully via Windows uninstaller" -ForegroundColor Green
                            return $true
                        }
                    }
                }
            }
        }
    }
    catch {
        Write-Host "Registry uninstall failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    return $false
}

# Function to remove Zoom installation directories
function Remove-ZoomDirectories {
    Write-Host "Removing Zoom installation directories..." -ForegroundColor Yellow
    
    $installPaths = @(
        "${env:ProgramFiles}\Zoom",
        "${env:ProgramFiles(x86)}\Zoom",
        "${env:APPDATA}\Zoom",
        "${env:LOCALAPPDATA}\Zoom"
    )
    
    foreach ($path in $installPaths) {
        if (Test-Path $path) {
            Write-Host "Removing directory: $path" -ForegroundColor Yellow
            try {
                Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
                Write-Host "Successfully removed: $path" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to remove: $path - $($_.Exception.Message)" -ForegroundColor Red
                
                # Try to remove individual files if directory removal fails
                try {
                    Get-ChildItem -Path $path -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                    Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
                    Write-Host "Successfully removed files from: $path" -ForegroundColor Green
                }
                catch {
                    Write-Host "Could not remove some files in: $path" -ForegroundColor Red
                }
            }
        }
    }
}

# Function to remove Zoom user data
function Remove-ZoomUserData {
    Write-Host "Removing Zoom user data and settings..." -ForegroundColor Yellow
    
    $userDataPaths = @(
        "${env:APPDATA}\Zoom",
        "${env:LOCALAPPDATA}\Zoom",
        "${env:USERPROFILE}\Documents\Zoom",
        "${env:USERPROFILE}\Desktop\Zoom",
        "${env:USERPROFILE}\Videos\Zoom",
        "${env:USERPROFILE}\Downloads\zoom_*",
        "${env:TEMP}\Zoom*"
    )
    
    foreach ($path in $userDataPaths) {
        if ($path -like "*\*") {
            # Handle wildcard paths
            $parentPath = Split-Path $path -Parent
            $pattern = Split-Path $path -Leaf
            
            if (Test-Path $parentPath) {
                $matchingItems = Get-ChildItem -Path $parentPath -Filter $pattern -ErrorAction SilentlyContinue
                foreach ($item in $matchingItems) {
                    Write-Host "Removing user data: $($item.FullName)" -ForegroundColor Yellow
                    try {
                        Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction Stop
                        Write-Host "Successfully removed user data: $($item.FullName)" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "Failed to remove user data: $($item.FullName) - $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
            }
        }
        else {
            if (Test-Path $path) {
                Write-Host "Removing user data: $path" -ForegroundColor Yellow
                try {
                    Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
                    Write-Host "Successfully removed user data: $path" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to remove user data: $path - $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
}

# Function to remove Zoom from registry
function Remove-ZoomRegistry {
    Write-Host "Cleaning Zoom registry entries..." -ForegroundColor Yellow
    
    $registryPaths = @(
        "HKCU:\SOFTWARE\Zoom",
        "HKLM:\SOFTWARE\Zoom",
        "HKCU:\SOFTWARE\Classes\ZoomLauncher",
        "HKLM:\SOFTWARE\Classes\ZoomLauncher",
        "HKCU:\SOFTWARE\Classes\zoommtg",
        "HKLM:\SOFTWARE\Classes\zoommtg",
        "HKCU:\SOFTWARE\Classes\zoomus",
        "HKLM:\SOFTWARE\Classes\zoomus"
    )
    
    foreach ($regPath in $registryPaths) {
        if (Test-Path $regPath) {
            Write-Host "Removing registry key: $regPath" -ForegroundColor Yellow
            try {
                Remove-Item -Path $regPath -Recurse -Force -ErrorAction Stop
                Write-Host "Successfully removed registry key: $regPath" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to remove registry key: $regPath - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    # Remove uninstall entries
    try {
        $uninstallPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($uninstallPath in $uninstallPaths) {
            $programs = Get-ItemProperty $uninstallPath -ErrorAction SilentlyContinue | Where-Object { 
                $_.DisplayName -like "*Zoom*" -and $_.DisplayName -notlike "*Zoom Player*"
            }
            
            foreach ($program in $programs) {
                $keyName = $program.PSChildName
                $fullPath = $uninstallPath.Replace("*", $keyName)
                Write-Host "Removing uninstall entry: $fullPath" -ForegroundColor Yellow
                try {
                    Remove-Item -Path $fullPath -Force -ErrorAction Stop
                    Write-Host "Successfully removed uninstall entry: $fullPath" -ForegroundColor Green
                }
                catch {
                    Write-Host "Failed to remove uninstall entry: $fullPath - $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }
    }
    catch {
        Write-Host "Registry cleanup failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Remove URL protocol handlers
    try {
        $urlProtocols = @("zoommtg", "zoomus", "zoomphonecall")
        foreach ($protocol in $urlProtocols) {
            $protocolPath = "HKCU:\SOFTWARE\Classes\$protocol"
            if (Test-Path $protocolPath) {
                Write-Host "Removing URL protocol: $protocol" -ForegroundColor Yellow
                Remove-Item -Path $protocolPath -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
    catch {
        Write-Host "URL protocol cleanup failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Function to remove Zoom shortcuts
function Remove-ZoomShortcuts {
    Write-Host "Removing Zoom shortcuts..." -ForegroundColor Yellow
    
    $shortcutPaths = @(
        "${env:USERPROFILE}\Desktop\Zoom.lnk",
        "${env:USERPROFILE}\Desktop\Start Zoom.lnk",
        "${env:APPDATA}\Microsoft\Windows\Start Menu\Programs\Zoom.lnk",
        "${env:APPDATA}\Microsoft\Windows\Start Menu\Programs\Start Zoom.lnk",
        "${env:ALLUSERSPROFILE}\Microsoft\Windows\Start Menu\Programs\Zoom.lnk",
        "${env:ALLUSERSPROFILE}\Microsoft\Windows\Start Menu\Programs\Start Zoom.lnk",
        "${env:ALLUSERSPROFILE}\Desktop\Zoom.lnk",
        "${env:ALLUSERSPROFILE}\Desktop\Start Zoom.lnk"
    )
    
    foreach ($shortcut in $shortcutPaths) {
        if (Test-Path $shortcut) {
            Write-Host "Removing shortcut: $shortcut" -ForegroundColor Yellow
            try {
                Remove-Item -Path $shortcut -Force -ErrorAction Stop
                Write-Host "Successfully removed shortcut: $shortcut" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to remove shortcut: $shortcut - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

# Function to remove Zoom from PATH
function Remove-ZoomFromPath {
    Write-Host "Removing Zoom from PATH environment variable..." -ForegroundColor Yellow
    
    try {
        # Check user PATH
        $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($userPath -and $userPath -match "Zoom") {
            $newUserPath = ($userPath -split ';' | Where-Object { $_ -notmatch "Zoom" }) -join ';'
            [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
            Write-Host "Removed Zoom from user PATH" -ForegroundColor Green
        }
        
        # Check system PATH (requires admin)
        if (Test-IsAdmin) {
            $systemPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
            if ($systemPath -and $systemPath -match "Zoom") {
                $newSystemPath = ($systemPath -split ';' | Where-Object { $_ -notmatch "Zoom" }) -join ';'
                [Environment]::SetEnvironmentVariable("PATH", $newSystemPath, "Machine")
                Write-Host "Removed Zoom from system PATH" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "Failed to clean PATH: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to remove Zoom startup entries
function Remove-ZoomStartup {
    Write-Host "Removing Zoom startup entries..." -ForegroundColor Yellow
    
    try {
        $startupPaths = @(
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
        )
        
        foreach ($startupPath in $startupPaths) {
            if (Test-Path $startupPath) {
                $startupItems = Get-ItemProperty $startupPath -ErrorAction SilentlyContinue
                foreach ($property in $startupItems.PSObject.Properties) {
                    if ($property.Name -like "*Zoom*" -or $property.Value -like "*Zoom*") {
                        Write-Host "Removing startup entry: $($property.Name)" -ForegroundColor Yellow
                        try {
                            Remove-ItemProperty -Path $startupPath -Name $property.Name -Force -ErrorAction Stop
                            Write-Host "Successfully removed startup entry: $($property.Name)" -ForegroundColor Green
                        }
                        catch {
                            Write-Host "Failed to remove startup entry: $($property.Name) - $($_.Exception.Message)" -ForegroundColor Red
                        }
                    }
                }
            }
        }
    }
    catch {
        Write-Host "Startup cleanup failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# Function to verify complete removal
function Test-ZoomRemoval {
    Write-Host "Verifying Zoom removal..." -ForegroundColor Yellow
    
    $foundItems = @()
    
    # Check installation paths
    $installPaths = @(
        "${env:ProgramFiles}\Zoom",
        "${env:ProgramFiles(x86)}\Zoom",
        "${env:APPDATA}\Zoom",
        "${env:LOCALAPPDATA}\Zoom"
    )
    
    foreach ($path in $installPaths) {
        if (Test-Path $path) {
            $foundItems += "Directory: $path"
        }
    }
    
    # Check registry
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
                $foundItems += "Registry: $($programs.DisplayName)"
            }
        }
    }
    catch {
        # Registry check failed
    }
    
    # Check for running processes
    $zoomProcesses = Get-Process -Name "Zoom*" -ErrorAction SilentlyContinue
    if ($zoomProcesses) {
        $foundItems += "Running processes: $($zoomProcesses.Name -join ', ')"
    }
    
    if ($foundItems.Count -eq 0) {
        Write-Host "Zoom has been completely removed from the system!" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "Some Zoom components may still remain:" -ForegroundColor Yellow
        foreach ($item in $foundItems) {
            Write-Host "  - $item" -ForegroundColor Yellow
        }
        return $false
    }
}

# Main execution
try {
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "Zoom Complete Uninstall Script" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    
    # Check if running as admin
    if (-not (Test-IsAdmin)) {
        Write-Host "Warning: Not running as administrator. Some cleanup operations may fail." -ForegroundColor Yellow
        Write-Host "For complete removal, consider running as administrator." -ForegroundColor Yellow
    }
    
    # Confirmation prompt
    $confirm = Read-Host "Are you sure you want to completely remove Zoom and ALL its data? (y/N)"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Host "Uninstall cancelled by user." -ForegroundColor Yellow
        exit 0
    }
    
    # Step 1: Stop Zoom processes
    Stop-ZoomProcesses
    
    # Step 2: Try official uninstaller first
    Uninstall-ZoomFromRegistry
    
    # Step 3: Remove installation directories
    Remove-ZoomDirectories
    
    # Step 4: Remove user data
    Remove-ZoomUserData
    
    # Step 5: Clean registry
    Remove-ZoomRegistry
    
    # Step 6: Remove shortcuts
    Remove-ZoomShortcuts
    
    # Step 7: Remove from PATH
    Remove-ZoomFromPath
    
    # Step 8: Remove startup entries
    Remove-ZoomStartup
    
    # Step 9: Final process cleanup
    Stop-ZoomProcesses
    
    # Step 10: Verify removal
    Write-Host "`nVerification Results:" -ForegroundColor Cyan
    $completelyRemoved = Test-ZoomRemoval
    
    if ($completelyRemoved) {
        Write-Host "`nZoom has been completely uninstalled!" -ForegroundColor Green
        Write-Host "You may need to restart your computer for all changes to take effect." -ForegroundColor Yellow
    }
    else {
        Write-Host "`nZoom removal completed with some remaining components." -ForegroundColor Yellow
        Write-Host "You may need to manually remove any remaining items listed above." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "An error occurred during uninstall: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nZoom uninstall script completed." -ForegroundColor Cyan
