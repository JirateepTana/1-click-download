Write-Host "Uninstalling Git and cleaning up all traces..." -ForegroundColor Yellow

# 1. Uninstall Git using winget
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Trying to uninstall Git using winget..." -ForegroundColor Cyan
    try {
        winget uninstall --id Git.Git --accept-source-agreements --silent
    }
    catch {
        Write-Host "winget uninstall failed or Git not found via winget." -ForegroundColor Gray
    }
}

# 2. Uninstall Git using Chocolatey
if (Get-Command choco -ErrorAction SilentlyContinue) {
    Write-Host "Trying to uninstall Git using Chocolatey..." -ForegroundColor Cyan
    try {
        choco uninstall git -y
    }
    catch {
        Write-Host "Chocolatey uninstall failed or Git not found via choco." -ForegroundColor Gray
    }
}

# 3. Remove Git from common installation directories
$gitPaths = @(
    "$env:ProgramFiles\Git",
    "$env:ProgramFiles(x86)\Git",
    "$env:LOCALAPPDATA\Programs\Git"
)
foreach ($path in $gitPaths) {
    if (Test-Path $path) {
        try {
            Remove-Item $path -Recurse -Force -ErrorAction Stop
            Write-Host "Removed: $path" -ForegroundColor Green
        }
        catch {
            Write-Host "Could not remove: $path" -ForegroundColor Red
        }
    }
}

# 4. Remove Git from PATH (User and Machine)
function Remove-GitFromPath($scope) {
    $pathVar = [Environment]::GetEnvironmentVariable("PATH", $scope)
    if ($pathVar) {
        $newPath = ($pathVar -split ";") | Where-Object { $_ -notmatch "Git\\bin" }  -join ";"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, $scope)
        Write-Host "Removed Git from $scope PATH." -ForegroundColor Cyan
    }
}
Remove-GitFromPath "User"
Remove-GitFromPath "Machine"

# 5. Remove Git cache and config folders
$gitCachePaths = @(
    "$env:USERPROFILE\.gitconfig",
    "$env:USERPROFILE\.git-credentials",
    "$env:USERPROFILE\.gitkraken",
    "$env:USERPROFILE\.config\git",
    "$env:APPDATA\Git",
    "$env:LOCALAPPDATA\Git"
)
foreach ($path in $gitCachePaths) {
    if (Test-Path $path) {
        try {
            Remove-Item $path -Recurse -Force -ErrorAction Stop
            Write-Host "Removed: $path" -ForegroundColor Green
        }
        catch {
            Write-Host "Could not remove: $path" -ForegroundColor Red
        }
    }
}

# 6. Remove Git registry entries (not GitHub Desktop)
Write-Host "Searching for and removing Git registry entries (not GitHub Desktop)..." -ForegroundColor Yellow
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
foreach ($regPath in $regPaths) {
    Get-ItemProperty $regPath -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -like "*Git*" -and $_.DisplayName -notlike "*GitHub*"
    } | ForEach-Object {
        if ($_.PSChildName) {
            try {
                Remove-Item -Path "$regPath\$($_.PSChildName)" -Recurse -Force
                Write-Host "Removed registry entry: $($_.DisplayName)" -ForegroundColor Green
            }
            catch {
                Write-Host "Could not remove registry entry: $($_.DisplayName)" -ForegroundColor Red
            }
        }
    }
}

Write-Host "All Git installations, cache, config, and registry entries (excluding GitHub Desktop) have been removed (if found)." -ForegroundColor Green
Write-Host "You may need to restart your computer to complete the cleanup." -ForegroundColor Yellow