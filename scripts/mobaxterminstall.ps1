# Robust MobaXterm Community Edition Portable/Personal downloader and runner

$downloadDir = "$env:USERPROFILE\Downloads"
$zipPath = Join-Path $downloadDir "MobaXterm_Portable.zip"
$mobaxtermUrl = "https://download.mobatek.net/2412024011102/MobaXterm_Portable_v24.1.zip"

# Try to find any MobaXterm exe first
Write-Host "Searching for any MobaXterm executable before download/extract..."
$exePath = Get-ChildItem -Path $downloadDir -Recurse -Include "MobaXterm_Portable.exe", "MobaXterm_Personal_*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $exePath) {
    # Download if not already present
    if (-not (Test-Path $zipPath)) {
        Write-Host "Downloading MobaXterm..."
        Invoke-WebRequest -Uri $mobaxtermUrl -OutFile $zipPath
    }
    else {
        Write-Host "MobaXterm ZIP already exists. Skipping download."
    }

    # Extract
    Write-Host "Extracting MobaXterm..."
    Expand-Archive -Path $zipPath -DestinationPath $downloadDir -Force

    # Wait a moment for file system to update
    Start-Sleep -Seconds 2
    Write-Host "Searching for any MobaXterm executable after extraction..."
    $exePath = Get-ChildItem -Path $downloadDir -Recurse -Include "MobaXterm_Portable.exe", "MobaXterm_Personal_*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
}


# List all MobaXterm executables found in Downloads
Write-Host "`nChecking for all MobaXterm executables in $downloadDir ..."
$allExe = Get-ChildItem -Path $downloadDir -Recurse -Include "MobaXterm_Portable.exe", "MobaXterm_Personal_*.exe" -ErrorAction SilentlyContinue
if ($allExe) {
    Write-Host "Found the following MobaXterm executables:"
    $allExe | ForEach-Object { Write-Host $_.FullName }
}
else {
    Write-Host "No MobaXterm executables found in $downloadDir."
}

