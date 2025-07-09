# Check if Node.js is installed
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js is not installed. Please install Node.js first from https://nodejs.org/" -ForegroundColor Red
    exit
}
else {
    Write-Host "Node.js found: $(node -v)" -ForegroundColor Green
}

# Install NestJS CLI globally
Write-Host "Installing NestJS CLI globally..." -ForegroundColor Cyan
npm install -g @nestjs/cli

# Verify installation
if (-not (Get-Command nest -ErrorAction SilentlyContinue)) {
    Write-Host "Nest CLI installation failed." -ForegroundColor Red
    exit
}
else {
    Write-Host "Nest CLI installed successfully: $(nest --version)" -ForegroundColor Green
}
