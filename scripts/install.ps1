# install.ps1
$logPath = ".\logs\install-log.txt"
$apps = @(
    "nodejs",
    "git",
    "vscode",
    "docker-desktop",
    "7zip"
)

Write-Host "1-Click Installer Started..." -ForegroundColor Cyan
Start-Sleep -Seconds 1

foreach ($app in $apps) {
    Write-Host "Installing $app..." -ForegroundColor Yellow
    try {
        choco install $app -y | Tee-Object -FilePath $logPath -Append
        Write-Host "$app installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "Error installing $app: $_" -ForegroundColor Red
        Add-Content -Path $logPath -Value "Error installing $app: $_"
    }
    Start-Sleep -Seconds 1
}

Write-Host "`n✅ All installations attempted. Check logs/install-log.txt for results." -ForegroundColor Cyan
