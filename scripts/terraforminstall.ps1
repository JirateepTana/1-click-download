# Check if Terraform is already installed
Write-Host "Checking if Terraform CLI is already installed..." -ForegroundColor Yellow

# Check if terraform command is available in PATH
try {
    $terraformVersion = terraform version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Terraform is already installed and available in PATH." -ForegroundColor Green
        Write-Host "Current version: $($terraformVersion -split "`n" | Select-Object -First 1)" -ForegroundColor Cyan
        Write-Host "Installation skipped." -ForegroundColor Yellow
        exit 0
    }
}
catch {
    # Terraform not in PATH, continue with installation check
}

# Check common installation locations
$commonPaths = @(
    "${env:ProgramFiles}\Terraform\terraform.exe",
    "${env:LOCALAPPDATA}\Programs\Terraform\terraform.exe",
    "${env:ProgramData}\Terraform\terraform.exe",
    "C:\Terraform\terraform.exe",
    "${env:USERPROFILE}\terraform.exe"
)

foreach ($path in $commonPaths) {
    if (Test-Path $path) {
        Write-Host "Terraform found at: $path" -ForegroundColor Green
        Write-Host "But it's not in PATH environment variable." -ForegroundColor Yellow
        Write-Host "Adding to PATH..." -ForegroundColor Cyan
        
        $terraformDir = Split-Path -Parent $path
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        if ($currentPath -notlike "*$terraformDir*") {
            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$terraformDir", "Machine")
            Write-Host "Added Terraform to system PATH." -ForegroundColor Green
        }
        Write-Host "Installation skipped - Terraform already exists." -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "Terraform not found. Proceeding with installation..." -ForegroundColor Cyan

# Get latest Terraform version from HashiCorp API
Write-Host "Fetching latest Terraform version..." -ForegroundColor Cyan
try {
    $apiUrl = "https://api.releases.hashicorp.com/v1/releases/terraform/latest"
    $releaseInfo = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
    $latestVersion = $releaseInfo.version
    Write-Host "Latest version: $latestVersion" -ForegroundColor Green
}
catch {
    Write-Host "Failed to fetch latest version, using fallback..." -ForegroundColor Yellow
    $latestVersion = "1.5.0"  # Fallback version
}

# Download URL for Windows 64-bit
$downloadUrl = "https://releases.hashicorp.com/terraform/$latestVersion/terraform_${latestVersion}_windows_amd64.zip"
$downloadPath = "$env:TEMP\terraform_${latestVersion}_windows_amd64.zip"
$installDir = "${env:ProgramFiles}\Terraform"

Write-Host "Downloading Terraform $latestVersion from HashiCorp..." -ForegroundColor Cyan
try {
    # Download with progress
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath -UseBasicParsing
    Write-Host "Download completed successfully." -ForegroundColor Green
}
catch {
    Write-Host "Failed to download Terraform: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Installing Terraform..." -ForegroundColor Cyan
try {
    # Create installation directory
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
        Write-Host "Created installation directory: $installDir" -ForegroundColor Green
    }
    
    # Extract ZIP file
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($downloadPath, $installDir)
    
    Write-Host "Terraform extracted successfully." -ForegroundColor Green
}
catch {
    Write-Host "Failed to extract Terraform: $($_.Exception.Message)" -ForegroundColor Red
    Remove-Item $downloadPath -Force -ErrorAction SilentlyContinue
    exit 1
}

Write-Host "Setting up environment variables..." -ForegroundColor Cyan
try {
    # Add Terraform to system PATH
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*$installDir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$installDir", "Machine")
        Write-Host "Added Terraform to system PATH." -ForegroundColor Green
    }
    else {
        Write-Host "Terraform already in PATH." -ForegroundColor Yellow
    }
    
    # Set TERRAFORM_HOME environment variable (optional but useful)
    [Environment]::SetEnvironmentVariable("TERRAFORM_HOME", $installDir, "Machine")
    Write-Host "Set TERRAFORM_HOME environment variable." -ForegroundColor Green
    
}
catch {
    Write-Host "Failed to set environment variables: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Cleaning up installer..." -ForegroundColor Cyan
Remove-Item $downloadPath -Force

# Verify installation
Write-Host "Verifying installation..." -ForegroundColor Cyan
$terraformExe = Join-Path $installDir "terraform.exe"
if (Test-Path $terraformExe) {
    try {
        # Test terraform in new process (to pick up new PATH)
        $versionOutput = & $terraformExe version
        Write-Host "Installation verified successfully!" -ForegroundColor Green
        Write-Host "Installed version: $($versionOutput -split "`n" | Select-Object -First 1)" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Installation completed but verification failed. You may need to restart your terminal." -ForegroundColor Yellow
    }
}
else {
    Write-Host "Installation verification failed - terraform.exe not found." -ForegroundColor Red
}

Write-Host "`nTerraform CLI installation complete!" -ForegroundColor Green

# Show where Terraform is installed and how to access it
Write-Host "`n=== Terraform CLI Location & Access Information ===" -ForegroundColor Cyan
Write-Host "Terraform is installed at:" -ForegroundColor White
Write-Host "  $installDir" -ForegroundColor Yellow

Write-Host "`nEnvironment Variables:" -ForegroundColor White
Write-Host "  PATH: Updated to include Terraform directory" -ForegroundColor Green
Write-Host "  TERRAFORM_HOME: $installDir" -ForegroundColor Green

Write-Host "`nHow to use Terraform:" -ForegroundColor White
Write-Host "  1. Open new Command Prompt or PowerShell" -ForegroundColor Green
Write-Host "  2. Type 'terraform --version' to verify installation" -ForegroundColor Green
Write-Host "  3. Type 'terraform --help' to see available commands" -ForegroundColor Green
Write-Host "  4. Navigate to your project folder and run 'terraform init'" -ForegroundColor Green

Write-Host "`nCommon commands:" -ForegroundColor White
Write-Host "  terraform init     - Initialize working directory" -ForegroundColor Yellow
Write-Host "  terraform plan     - Show execution plan" -ForegroundColor Yellow
Write-Host "  terraform apply    - Apply configuration" -ForegroundColor Yellow
Write-Host "  terraform destroy  - Destroy infrastructure" -ForegroundColor Yellow

Write-Host "`nNext steps:" -ForegroundColor White
Write-Host "  1. Restart your terminal" -ForegroundColor Cyan
Write-Host "  2. Test: terraform --version" -ForegroundColor Cyan
Write-Host "  3. Visit: https://learn.hashicorp.com/terraform" -ForegroundColor Cyan

Write-Host "`nImportant: Restart your terminal for PATH changes to take effect." -ForegroundColor Red
