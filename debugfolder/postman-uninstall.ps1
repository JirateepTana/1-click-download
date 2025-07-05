# Postman Complete Uninstall Script
# This script completely removes Postman from the system including all user data and settings

Write-Host "Starting complete Postman uninstall process..." -ForegroundColor Yellow
Write-Host "WARNING: This will remove ALL Postman data including collections, environments, and settings!" -ForegroundColor Red

# Function to check if running as administrator
function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to force kill Postman processes
function Stop-PostmanProcesses {
    Write-Host "Stopping Postman processes..." -ForegroundColor Yellow
    
    $processes = @("Postman", "PostmanCanary", "Postman Agent")
    foreach ($processName in $processes) {
        try {
            $runningProcesses = Get-Process -Name $processName -ErrorAction SilentlyContinue
            if ($runningProcesses) {
                Write-Host "Stopping $processName processes..." -ForegroundColor Yellow
                Stop-Process -Name $processName -Force -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 2
            }
        }
        catch {
            # Process not running
        }
    }
}

# Function to uninstall via Windows Programs and Features
function Uninstall-PostmanFromRegistry {
    Write-Host "Attempting to uninstall Postman via Windows uninstaller..." -ForegroundColor Yellow
    
    try {
        # Check both HKLM and HKCU uninstall keys
        $regPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )
        
        foreach ($regPath in $regPaths) {
            $programs = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Where-Object { 
                $_.DisplayName -like "*Postman*"
            }
            
            foreach ($program in $programs) {
                if ($program.UninstallString) {
                    Write-Host "Found Postman uninstaller: $($program.DisplayName)" -ForegroundColor Green
                    
                    # Extract the uninstall command
                    $uninstallCmd = $program.UninstallString
                    
                    # Handle different uninstall string formats
                    if ($uninstallCmd -match '"([^"]+)"') {
                        $uninstallPath = $matches[1]
                        $arguments = $uninstallCmd.Replace("`"$uninstallPath`"", "").Trim()
                        
                        # Add silent flags
                        if ($arguments) {
                            $arguments += " /S /silent"
                        }
                        else {
                            $arguments = "/S /silent"
                        }
                        
                        Write-Host "Running uninstaller: $uninstallPath $arguments" -ForegroundColor Yellow
                        $process = Start-Process -FilePath $uninstallPath -ArgumentList $arguments -Wait -PassThru -ErrorAction SilentlyContinue
                        
                        if ($process.ExitCode -eq 0) {
                            Write-Host "Postman uninstalled successfully via Windows uninstaller" -ForegroundColor Green
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

# Function to remove Postman installation directories
function Remove-PostmanDirectories {
    Write-Host "Removing Postman installation directories..." -ForegroundColor Yellow
    
    $installPaths = @(
        "${env:LOCALAPPDATA}\Postman",
        "${env:ProgramFiles}\Postman",
        "${env:ProgramFiles(x86)}\Postman",
        "${env:APPDATA}\Postman"
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
            }
        }
    }
}

# Function to remove Postman user data
function Remove-PostmanUserData {
    Write-Host "Removing Postman user data and settings..." -ForegroundColor Yellow
    
    $userDataPaths = @(
        "${env:APPDATA}\Postman",
        "${env:LOCALAPPDATA}\Postman",
        "${env:USERPROFILE}\Postman",
        "${env:USERPROFILE}\Documents\Postman",
        "${env:USERPROFILE}\Desktop\Postman Files"
    )
    
    foreach ($path in $userDataPaths) {
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

# Function to remove Postman from registry
function Remove-PostmanRegistry {
    Write-Host "Cleaning Postman registry entries..." -ForegroundColor Yellow
    
    $registryPaths = @(
        "HKCU:\SOFTWARE\Postman",
        "HKLM:\SOFTWARE\Postman",
        "HKCU:\SOFTWARE\Classes\postman",
        "HKLM:\SOFTWARE\Classes\postman"
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
                $_.DisplayName -like "*Postman*"
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
}

# Function to remove Postman shortcuts
function Remove-PostmanShortcuts {
    Write-Host "Removing Postman shortcuts..." -ForegroundColor Yellow
    
    $shortcutPaths = @(
        "${env:USERPROFILE}\Desktop\Postman.lnk",
        "${env:APPDATA}\Microsoft\Windows\Start Menu\Programs\Postman.lnk",
        "${env:ALLUSERSPROFILE}\Microsoft\Windows\Start Menu\Programs\Postman.lnk",
        "${env:ALLUSERSPROFILE}\Desktop\Postman.lnk"
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

# Function to remove Postman from PATH
function Remove-PostmanFromPath {
    Write-Host "Removing Postman from PATH environment variable..." -ForegroundColor Yellow
    
    try {
        # Check user PATH
        $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($userPath -and $userPath -match "Postman") {
            $newUserPath = ($userPath -split ';' | Where-Object { $_ -notmatch "Postman" }) -join ';'
            [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
            Write-Host "Removed Postman from user PATH" -ForegroundColor Green
        }
        
        # Check system PATH (requires admin)
        if (Test-IsAdmin) {
            $systemPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
            if ($systemPath -and $systemPath -match "Postman") {
                $newSystemPath = ($systemPath -split ';' | Where-Object { $_ -notmatch "Postman" }) -join ';'
                [Environment]::SetEnvironmentVariable("PATH", $newSystemPath, "Machine")
                Write-Host "Removed Postman from system PATH" -ForegroundColor Green
            }
        }
    }
    catch {
        Write-Host "Failed to clean PATH: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to verify complete removal
function Test-PostmanRemoval {
    Write-Host "Verifying Postman removal..." -ForegroundColor Yellow
    
    $foundItems = @()
    
    # Check installation paths
    $installPaths = @(
        "${env:LOCALAPPDATA}\Postman",
        "${env:ProgramFiles}\Postman",
        "${env:ProgramFiles(x86)}\Postman",
        "${env:APPDATA}\Postman"
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
                $_.DisplayName -like "*Postman*"
            }
            if ($programs) {
                $foundItems += "Registry: $($programs.DisplayName)"
            }
        }
    }
    catch {
        # Registry check failed
    }
    
    if ($foundItems.Count -eq 0) {
        Write-Host "Postman has been completely removed from the system!" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "Some Postman components may still remain:" -ForegroundColor Yellow
        foreach ($item in $foundItems) {
            Write-Host "  - $item" -ForegroundColor Yellow
        }
        return $false
    }
}

# Main execution
try {
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "Postman Complete Uninstall Script" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    
    # Check if running as admin
    if (-not (Test-IsAdmin)) {
        Write-Host "Warning: Not running as administrator. Some cleanup operations may fail." -ForegroundColor Yellow
        Write-Host "For complete removal, consider running as administrator." -ForegroundColor Yellow
    }
    
    # Confirmation prompt
    $confirm = Read-Host "Are you sure you want to completely remove Postman and ALL its data? (y/N)"
    if ($confirm -ne 'y' -and $confirm -ne 'Y') {
        Write-Host "Uninstall cancelled by user." -ForegroundColor Yellow
        exit 0
    }
    
    # Step 1: Stop Postman processes
    Stop-PostmanProcesses
    
    # Step 2: Try official uninstaller first
    Uninstall-PostmanFromRegistry
    
    # Step 3: Remove installation directories
    Remove-PostmanDirectories
    
    # Step 4: Remove user data
    Remove-PostmanUserData
    
    # Step 5: Clean registry
    Remove-PostmanRegistry
    
    # Step 6: Remove shortcuts
    Remove-PostmanShortcuts
    
    # Step 7: Remove from PATH
    Remove-PostmanFromPath
    
    # Step 8: Verify removal
    Write-Host "`nVerification Results:" -ForegroundColor Cyan
    $completelyRemoved = Test-PostmanRemoval
    
    if ($completelyRemoved) {
        Write-Host "`nPostman has been completely uninstalled!" -ForegroundColor Green
        Write-Host "You may need to restart your computer for all changes to take effect." -ForegroundColor Yellow
    }
    else {
        Write-Host "`nPostman removal completed with some remaining components." -ForegroundColor Yellow
        Write-Host "You may need to manually remove any remaining items listed above." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "An error occurred during uninstall: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nPostman uninstall script completed." -ForegroundColor Cyan
