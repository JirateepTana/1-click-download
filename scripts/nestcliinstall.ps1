# Nest CLI Installation Script
# This script checks if Nest CLI is installed and installs it if not found

Write-Host "Checking for Nest CLI installation..." -ForegroundColor Yellow

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
        Write-Host "Node.js is not installed. Nest CLI requires Node.js." -ForegroundColor Red
        return $false
    }
    return $false
}

# Function to check if Nest CLI is installed
function Test-NestCLIInstalled {
    try {
        $nestVersion = nest --version 2>$null
        if ($nestVersion) {
            return $true
        }
    }
    catch {
        # Nest CLI not found
    }
    
    # Check npm global packages
    try {
        $npmList = npm list -g --depth=0 2>$null
        if ($npmList -and ($npmList -like "*@nestjs/cli*")) {
            return $true
        }
    }
    catch {
        # npm list failed
    }
    
    return $false
}

# Function to install Nest CLI
function Install-NestCLI {
    Write-Host "Nest CLI not found. Starting installation..." -ForegroundColor Green
    
    # Check if Node.js is installed first
    if (-not (Test-NodeJSInstalled)) {
        Write-Host "Node.js is required for Nest CLI. Please install Node.js first." -ForegroundColor Red
        return $false
    }
    
    # Install Nest CLI using npm
    try {
        Write-Host "Installing Nest CLI via npm..." -ForegroundColor Yellow
        
        # Install Nest CLI globally
        $process = Start-Process -FilePath "npm" -ArgumentList "install", "-g", "@nestjs/cli" -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -eq 0) {
            Write-Host "Nest CLI installed successfully!" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Nest CLI installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
            
            # Try with --force flag as backup
            Write-Host "Retrying with --force flag..." -ForegroundColor Yellow
            $process2 = Start-Process -FilePath "npm" -ArgumentList "install", "-g", "@nestjs/cli", "--force" -Wait -PassThru -NoNewWindow
            
            if ($process2.ExitCode -eq 0) {
                Write-Host "Nest CLI installed successfully with --force!" -ForegroundColor Green
                return $true
            }
            else {
                Write-Host "Nest CLI installation failed even with --force flag" -ForegroundColor Red
                return $false
            }
        }
    }
    catch {
        Write-Host "Error during Nest CLI installation: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to verify installation
function Test-NestCLIInstallation {
    Write-Host "Verifying Nest CLI installation..." -ForegroundColor Yellow
    
    if (Test-NestCLIInstalled) {
        try {
            # Get Nest CLI version
            $nestVersion = nest --version 2>$null
            if ($nestVersion) {
                Write-Host "Nest CLI is installed: $nestVersion" -ForegroundColor Green
            }
            
            # Check global npm location
            $npmPath = npm root -g 2>$null
            if ($npmPath) {
                $nestPath = Join-Path $npmPath "@nestjs\cli"
                if (Test-Path $nestPath) {
                    Write-Host "Nest CLI location: $nestPath" -ForegroundColor Green
                }
            }
            
            return $true
        }
        catch {
            Write-Host "Nest CLI is installed but version check failed" -ForegroundColor Yellow
            return $true
        }
    }
    else {
        Write-Host "Nest CLI installation verification failed" -ForegroundColor Red
        return $false
    }
}

# Main execution
try {
    # Check Node.js dependency first
    if (-not (Test-NodeJSInstalled)) {
        Write-Host "Node.js is required for Nest CLI but is not installed." -ForegroundColor Red
        Write-Host "Please install Node.js first from: https://nodejs.org/" -ForegroundColor Yellow
        exit 1
    }
    
    if (Test-NestCLIInstalled) {
        Write-Host "Nest CLI is already installed on this system." -ForegroundColor Green
        Test-NestCLIInstallation
    }
    else {
        $installSuccess = Install-NestCLI
        
        if ($installSuccess) {
            Start-Sleep -Seconds 2
            if (Test-NestCLIInstallation) {
                Write-Host "`nNest CLI installation completed successfully!" -ForegroundColor Green
                Write-Host "You can now create NestJS projects using: nest new my-project" -ForegroundColor Cyan
            }
            else {
                Write-Host "Nest CLI installation may have failed. Please check manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Failed to install Nest CLI. Please try manual installation:" -ForegroundColor Red
            Write-Host "npm install -g @nestjs/cli" -ForegroundColor Cyan
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Nest CLI installation script completed." -ForegroundColor Cyan
