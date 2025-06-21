# install-node.ps1

# Set Node.js version and download URL
$version = "v22.16.0"
$zipUrl = "https://nodejs.org/dist/$version/node-$version-win-x64.zip"
$zipPath = "$env:TEMP\nodejs.zip"
$installPath = "D:\nodejs"  # Change this as needed

# Ensure install directory exists
if (-not (Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath | Out-Null
}

# Check if Node.js is already installed in the folder
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

# Find the extracted subfolder
$subfolder = Get-ChildItem -Path $installPath | Where-Object { $_.PSIsContainer } | Select-Object -First 1

if ($subfolder) {
    # Move all files from subfolder to $installPath
    Get-ChildItem -Path $subfolder.FullName | Move-Item -Destination $installPath -Force
    Remove-Item -Path $subfolder.FullName -Recurse -Force
}

# Remove ZIP
Remove-Item $zipPath -Force

# Verify install
$nodePath = "$installPath\node.exe"
if (Test-Path $nodePath) {
    Write-Host "Node.js extracted successfully."
    & $nodePath -v
} else {
    Write-Error "Extraction failed. Node.js not found in $installPath"
}
