# install-node.ps1

# Set installation path
$installPath = "D:\nodejs"  # Change this if needed
$zipPath = "$env:TEMP\nodejs.zip"

# Get the latest LTS version info from Node.js distribution index
Write-Host "Fetching latest LTS Node.js version..."
$indexJson = Invoke-RestMethod -Uri "https://nodejs.org/dist/index.json"

# Find latest LTS version (you can adjust this to use 'latest' instead of LTS if you want)
$latest = $indexJson | Where-Object { $_.lts } | Select-Object -First 1
$version = $latest.version  # e.g., "v22.2.0"

Write-Host "Latest LTS version detected: $version"

# Construct download URL
$zipUrl = "https://nodejs.org/dist/$version/node-$version-win-x64.zip"

# Ensure install directory exists
if (-not (Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath | Out-Null
}

# Check if Node.js is already installed
if (Test-Path "$installPath\node.exe") {
    Write-Host "Node.js is already installed at $installPath"
    & "$installPath\node.exe" -v
    exit 0
}

# Download ZIP
Write-Host "Downloading Node.js from $zipUrl"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

# Extract ZIP
Write-Host "Extracting Node.js to $installPath"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $installPath)

# Move files if there's a subfolder
$subfolder = Get-ChildItem -Path $installPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1
if ($subfolder) {
    Get-ChildItem -Path $subfolder.FullName | Move-Item -Destination $installPath -Force
    Remove-Item -Path $subfolder.FullName -Recurse -Force
}

# Cleanup
Remove-Item $zipPath -Force

# Verify install
$nodePath = "$installPath\node.exe"
$npmPath = "$installPath\npm.cmd"

if (Test-Path $nodePath) {
    Write-Host "Node.js installed successfully:"
    & $nodePath -v

    if (Test-Path $npmPath) {
        Write-Host "npm version:"
        & $npmPath -v
    } else {
        Write-Warning "npm not found!"
    }

    # Update user PATH if necessary
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if (-not ($currentPath -split ";" | Where-Object { $_ -eq $installPath })) {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$installPath", "User")
        Write-Host "Added $installPath to user PATH. Restart your terminal to use 'node' globally."
    } else {
        Write-Host "$installPath is already in user PATH."
    }
} else {
    Write-Error "Installation failed. Node.js not found in $installPath"
}
