# Visual Studio Code Installation Script
Write-Host "Installing Visual Studio Code..." -ForegroundColor Green

try {
    # Check if winget is available
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Using winget to install Visual Studio Code..."
        winget install -e --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Visual Studio Code installed successfully!" -ForegroundColor Green
        }
        else {
            Write-Host "winget installation failed, trying direct download..." -ForegroundColor Yellow
            
            # Fallback to direct download
            $url = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
            $outputPath = "$env:TEMP\VSCodeUserSetup.exe"
            
            Write-Host "Downloading Visual Studio Code..."
            Invoke-WebRequest -Uri $url -OutFile $outputPath -UseBasicParsing
            
            Write-Host "Installing Visual Studio Code..."
            Start-Process -FilePath $outputPath -ArgumentList "/VERYSILENT", "/NORESTART", "/MERGETASKS=!runcode" -Wait
            
            # Clean up
            Remove-Item $outputPath -Force -ErrorAction SilentlyContinue
            Write-Host "Visual Studio Code installed successfully!" -ForegroundColor Green
        }
    }
    else {
        # Direct download method
        $url = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user"
        $outputPath = "$env:TEMP\VSCodeUserSetup.exe"
        
        Write-Host "Downloading Visual Studio Code..."
        Invoke-WebRequest -Uri $url -OutFile $outputPath -UseBasicParsing
        
        Write-Host "Installing Visual Studio Code..."
        Start-Process -FilePath $outputPath -ArgumentList "/VERYSILENT", "/NORESTART", "/MERGETASKS=!runcode" -Wait
        
        # Clean up
        Remove-Item $outputPath -Force -ErrorAction SilentlyContinue
        Write-Host "Visual Studio Code installed successfully!" -ForegroundColor Green
    }
}
catch {
    Write-Host "Error installing Visual Studio Code: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Visual Studio Code installation completed." -ForegroundColor Green
