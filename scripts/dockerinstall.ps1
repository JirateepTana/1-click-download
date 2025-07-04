# Check if Docker is installed
if (Get-Command "docker" -ErrorAction SilentlyContinue) {
    Write-Host "Docker is already installed. Skipping installation."
    exit
}

Write-Host "Fetching latest Docker Desktop download URL..."

# Official Docker Desktop download URL (always points to latest)
$installerUrl = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
$installerPath = "C:\DockerDesktopInstaller.exe"

Write-Host "Downloading Docker Desktop from $installerUrl..."
Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

Write-Host "Running Docker Desktop installer silently..."
Start-Process -FilePath $installerPath -ArgumentList "install", "--quiet" -Wait

Write-Host "Cleaning up installer..."
Remove-Item $installerPath -Force

Write-Host "Docker Desktop installation complete. You may need to reboot your computer."