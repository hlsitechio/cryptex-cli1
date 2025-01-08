# Cryptex Installation Script
$ErrorActionPreference = "Stop"

Write-Host "🧙‍♂️ Summoning Cryptex..."

# Check for required commands
function Test-Command($cmd) {
    if (!(Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Error: '$cmd' not found. Please install it first."
        Exit 1
    }
}

Test-Command "git"
Test-Command "node"
Test-Command "npm"

# Set installation directory
$installDir = Join-Path $env:USERPROFILE ".cryptex"
Write-Host "Installing to: $installDir"

# Remove existing installation if present
Remove-Item -Recurse -Force $installDir -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

# Clone repository
Write-Host "Cloning repository..."
git clone https://github.com/hlsitechio/cryptexcli1.git $installDir

# Install dependencies
Write-Host "Installing dependencies..."
Set-Location (Join-Path $installDir "cryptex-cli")
npm install --no-package-lock

# Create global command
Write-Host "Creating global command..."
$binDir = Join-Path $env:USERPROFILE "bin"
New-Item -ItemType Directory -Force -Path $binDir | Out-Null

$cmdPath = Join-Path $binDir "cryptex.cmd"
@"
@echo off
node "$installDir\cryptex-cli\bin\cryptex.js" %*
"@ | Out-File -FilePath $cmdPath -Encoding ASCII

# Add to PATH if not already there
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notmatch [regex]::Escape($binDir)) {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$binDir", "User")
    $env:Path = "$env:Path;$binDir"
}

Write-Host "`n✨ Installation complete! Try 'cryptex interact' to begin your magical journey."
Write-Host "Note: If 'cryptex' is not recognized, you may need to restart your terminal."