$InstallPath = "C:\nodejs"  # Always use C:\nodejs

Write-Output "DEBUG: InstallPath is '$InstallPath'"

if (-not $InstallPath) {
    Write-Error "InstallPath is null or empty."
    exit 1
}


$zipPath = "$env:TEMP\nodejs.zip"
Write-Output "Fetching latest LTS Node.js version..."
$indexJson = Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json"
$latest = $indexJson | Where-Object { $_.lts } | Select-Object -First 1
$version = $latest.version
Write-Output "Latest LTS version detected: $version"
$zipUrl = "https://nodejs.org/dist/$version/node-$version-win-x64.zip"

if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath | Out-Null
}

if (Test-Path "$InstallPath\node.exe") {
    Write-Output "Node.js is already installed at $InstallPath"
    & "$InstallPath\node.exe" -v
    exit 0
}

Write-Output "Downloading Node.js from $zipUrl"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

Write-Output "Extracting Node.js to $InstallPath"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $InstallPath)

$subfolder = Get-ChildItem -Path $InstallPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1
if ($subfolder -and $subfolder.FullName) {
    Get-ChildItem -Path $subfolder.FullName | Move-Item -Destination $InstallPath -Force
    Remove-Item -Path $subfolder.FullName -Recurse -Force
}

Remove-Item $zipPath -Force

$nodePath = "$InstallPath\node.exe"
$npmPath = "$InstallPath\npm.cmd"

if (Test-Path $nodePath) {
    Write-Output "Node.js installed successfully:"
    & $nodePath -v
    if (Test-Path $npmPath) {
        Write-Output "npm version:"
        & $npmPath -v
    }
    else {
        Write-Output "npm not found!"
    }
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not ($currentPath -split ";" | Where-Object { $_ -eq $InstallPath })) {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$InstallPath", "User")
        Write-Output "Added $InstallPath to user PATH. Restart your terminal to use 'node' globally."
    }
    else {
        Write-Output "$InstallPath is already in user PATH."
    }
}
else {
    Write-Output "Installation failed. Node.js not found in $InstallPath"
}