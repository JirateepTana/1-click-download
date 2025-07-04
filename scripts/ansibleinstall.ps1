# Ansible CLI Installation Script
# This script checks if Ansible is installed and installs it if not found

Write-Host "Checking for Ansible installation..." -ForegroundColor Yellow

# Function to check if Python is installed
function Test-PythonInstalled {
    try {
        $pythonVersion = python --version 2>$null
        if ($pythonVersion) {
            Write-Host "Python is installed: $pythonVersion" -ForegroundColor Green
            return $true
        }
    }
    catch {
        # Python not found
    }
    
    try {
        $python3Version = python3 --version 2>$null
        if ($python3Version) {
            Write-Host "Python3 is installed: $python3Version" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "Python is not installed. Ansible requires Python." -ForegroundColor Red
        return $false
    }
    return $false
}

# Function to check if Ansible is installed
function Test-AnsibleInstalled {
    try {
        $ansibleVersion = ansible --version 2>$null
        if ($ansibleVersion -and $ansibleVersion -like "*ansible*") {
            return $true
        }
    }
    catch {
        # Ansible not found
    }
    
    # Check pip packages
    try {
        $pipList = pip list 2>$null
        if ($pipList -and ($pipList -like "*ansible*")) {
            return $true
        }
    }
    catch {
        # pip list failed
    }
    
    return $false
}

# Function to install Ansible
function Install-Ansible {
    Write-Host "Ansible not found. Starting installation..." -ForegroundColor Green
    
    # Check if Python is installed first
    if (-not (Test-PythonInstalled)) {
        Write-Host "Python is required for Ansible. Trying to install Python first..." -ForegroundColor Yellow
        
        # Try to install Python via winget
        try {
            winget install Python.Python.3.11 --silent --accept-source-agreements --accept-package-agreements 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Python installed successfully!" -ForegroundColor Green
                # Refresh PATH
                $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
            }
            else {
                Write-Host "Failed to install Python automatically. Please install Python manually." -ForegroundColor Red
                return $false
            }
        }
        catch {
            Write-Host "Failed to install Python automatically. Please install Python manually." -ForegroundColor Red
            return $false
        }
    }
    
    # Try winget first
    try {
        Write-Host "Trying winget installation..." -ForegroundColor Yellow
        winget install Ansible.Ansible --silent --accept-source-agreements --accept-package-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Ansible installed successfully via winget!" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "winget installation failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    # Try pip installation
    try {
        Write-Host "Installing Ansible via pip..." -ForegroundColor Yellow
        
        # Upgrade pip first
        Start-Process -FilePath "pip" -ArgumentList "install", "--upgrade", "pip" -Wait -PassThru -NoNewWindow | Out-Null
        
        # Install Ansible
        $process2 = Start-Process -FilePath "pip" -ArgumentList "install", "ansible" -Wait -PassThru -NoNewWindow
        
        if ($process2.ExitCode -eq 0) {
            Write-Host "Ansible installed successfully via pip!" -ForegroundColor Green
            
            # Add Python Scripts to PATH if needed
            $pythonScripts = "${env:LOCALAPPDATA}\Programs\Python\Python311\Scripts"
            if (Test-Path $pythonScripts) {
                $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
                if ($currentPath -notlike "*$pythonScripts*") {
                    Write-Host "Adding Python Scripts to PATH..." -ForegroundColor Yellow
                    [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$pythonScripts", "User")
                    $env:PATH = "$env:PATH;$pythonScripts"
                }
            }
            
            return $true
        }
        else {
            Write-Host "Ansible installation failed via pip with exit code: $($process2.ExitCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error during pip installation: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Try chocolatey as backup
    try {
        Write-Host "Trying Chocolatey installation..." -ForegroundColor Yellow
        $chocoCheck = choco --version 2>$null
        if ($chocoCheck) {
            choco install ansible -y
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Ansible installed successfully via Chocolatey!" -ForegroundColor Green
                return $true
            }
        }
        else {
            Write-Host "Chocolatey not found, skipping..." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Chocolatey installation failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    Write-Host "All installation methods failed. Please install Ansible manually:" -ForegroundColor Red
    Write-Host "pip install ansible" -ForegroundColor Cyan
    return $false
}

# Function to verify installation
function Test-AnsibleInstallation {
    Write-Host "Verifying Ansible installation..." -ForegroundColor Yellow
    
    if (Test-AnsibleInstalled) {
        try {
            # Get Ansible version
            $ansibleVersion = ansible --version 2>$null
            if ($ansibleVersion) {
                $versionLine = ($ansibleVersion -split "`n")[0]
                Write-Host "Ansible is installed: $versionLine" -ForegroundColor Green
            }
            
            # Check ansible-playbook
            $playbookVersion = ansible-playbook --version 2>$null
            if ($playbookVersion) {
                Write-Host "ansible-playbook is also available" -ForegroundColor Green
            }
            
            return $true
        }
        catch {
            Write-Host "Ansible is installed but version check failed" -ForegroundColor Yellow
            return $true
        }
    }
    else {
        Write-Host "Ansible installation verification failed" -ForegroundColor Red
        return $false
    }
}

# Main execution
try {
    if (Test-AnsibleInstalled) {
        Write-Host "Ansible is already installed on this system." -ForegroundColor Green
        Test-AnsibleInstallation
    }
    else {
        $installSuccess = Install-Ansible
        
        if ($installSuccess) {
            Start-Sleep -Seconds 3
            Write-Host "`nRefreshing environment variables..." -ForegroundColor Yellow
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
            
            if (Test-AnsibleInstallation) {
                Write-Host "`nAnsible installation completed successfully!" -ForegroundColor Green
                Write-Host "You can now use Ansible commands like: ansible --version" -ForegroundColor Cyan
                Write-Host "Create playbooks and run them with: ansible-playbook playbook.yml" -ForegroundColor Cyan
            }
            else {
                Write-Host "Ansible installation may have failed. Please check manually." -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "Failed to install Ansible. Please try manual installation." -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Ansible installation script completed." -ForegroundColor Cyan
