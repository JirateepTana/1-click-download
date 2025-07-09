# Angular CLI Installation Script
# This script checks if Angular CLI is installed and installs it if not found

Write-Host "Checking for Angular CLI installation..." -ForegroundColor Yellow

# Function to check if Node.js is installed
function Test-NodeJSInstalled {
    try {
        $nodeVersion = node --version 2>$null
        if ($nodeVersion) {
            Write-Host "Node.js is installed: $nodeVersion" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "Node.js is not installed. Angular CLI requires Node.js." -ForegroundColor Red
        return $false
    }
    return $false
}

# Function to check if Angular CLI is installed
function Test-AngularCLIInstalled {
    try {
        $ngVersion = ng version --skip-git 2>$null
        if ($ngVersion -and $ngVersion -like "*Angular CLI*") {
            return $true
        }
    }
    catch {
        # Angular CLI not found
    }
    
    # Check npm global packages
    try {
        $npmList = npm list -g --depth=0 2>$null
        if ($npmList -and ($npmList -like "*@angular/cli*")) {
            return $true
        }
    }
    catch {
        # npm list failed
    }
    
    return $false
}

# Function to install Angular CLI
function Install-AngularCLI {
    Write-Host "Angular CLI not found. Starting installation..." -ForegroundColor Green
    
    # Check if Node.js is installed first
    if (-not (Test-NodeJSInstalled)) {
        Write-Host "Node.js is required for Angular CLI. Please install Node.js first." -ForegroundColor Red
        return $false
    }
    
    # Install Angular CLI using npm
    try {
        Write-Host "Installing Angular CLI via npm..." -ForegroundColor Yellow
        
        # Install Angular CLI globally
        $process = Start-Process -FilePath "npm" -ArgumentList "install", "-g", "@angular/cli" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Host "Angular CLI installed successfully!" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Angular CLI installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
            
            # Try with --force flag as backup
            Write-Host "Retrying with --force flag..." -ForegroundColor Yellow
            $process2 = Start-Process -FilePath "npm" -ArgumentList "install", "-g", "@angular/cli", "--force" -Wait -PassThru -NoNewWindow
            
            if ($process2.ExitCode -eq 0) {
                Write-Host "Angular CLI installed successfully with --force!" -ForegroundColor Green
                return $true
            }
            else {
                Write-Host "Angular CLI installation failed even with --force flag" -ForegroundColor Red
                return $false
            }
        }
    }
    catch {
        Write-Host "Error during Angular CLI installation: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to verify installation
function Test-AngularCLIInstallation {
    Write-Host "Verifying Angular CLI installation..." -ForegroundColor Yellow
    
    if (Test-AngularCLIInstalled) {
        try {
            # Get Angular CLI version
            $ngVersion = ng version --skip-git 2>$null
            if ($ngVersion) {
                $versionLine = ($ngVersion -split "`n" | Where-Object { $_ -like "*Angular CLI*" })[0]
                if ($versionLine) {
                    Write-Host "Angular CLI is installed: $versionLine" -ForegroundColor Green
                }
                else {
                    Write-Host "Angular CLI is installed" -ForegroundColor Green
                }
            }
            
            # Check global npm location
            $npmPath = npm root -g 2>$null
            if ($npmPath) {
                $angularPath = Join-Path $npmPath "@angular\cli"
                if (Test-Path $angularPath) {
                    Write-Host "Angular CLI location: $angularPath" -ForegroundColor Green
                }
            }
            
            return $true
        }
        catch {
            Write-Host "Angular CLI is installed but version check failed" -ForegroundColor Yellow
            return $true
        }
    }
    else {
        Write-Host "Angular CLI installation verification failed" -ForegroundColor Red
        return $false
    }
}

# Main execution
try {
    # Check Node.js dependency first
    if (-not (Test-NodeJSInstalled)) {
        Write-Host "Node.js is required for Angular CLI but is not installed." -ForegroundColor Red
        Write-Host "Please install Node.js first from: https://nodejs.org/" -ForegroundColor Yellow
        exit 1
    }
    
    if (Test-AngularCLIInstalled) {
        Write-Host "Angular CLI is already installed on this system." -ForegroundColor Green
        Test-AngularCLIInstallation
    }
    else {
        $installSuccess = Install-AngularCLI
        
        if ($installSuccess) {
            Start-Sleep -Seconds 2
            if (Test-AngularCLIInstallation) {
                Write-Host "`nAngular CLI installation completed successfully!" -ForegroundColor Green
                Write-Host "You can now create Angular projects using: ng new my-app" -ForegroundColor Cyan
            }
            else {
                Write-Host "Angular CLI installation may have failed. Please check manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Failed to install Angular CLI. Please try manual installation:" -ForegroundColor Red
            Write-Host "npm install -g @angular/cli" -ForegroundColor Cyan
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Angular CLI installation script completed." -ForegroundColor Cyan
