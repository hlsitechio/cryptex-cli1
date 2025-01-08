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

# Set npm prefix to user directory to avoid permission issues
$npmPrefix = Join-Path $env:USERPROFILE ".npm-packages"
Write-Host "Setting npm prefix to: $npmPrefix"
npm config set prefix $npmPrefix

# Add npm bin folder to the current PATH
$npmBin = Join-Path $npmPrefix "bin"
if ($env:Path -notmatch [regex]::Escape($npmBin)) {
    Write-Host "Adding $npmBin to PATH for this session..."
    $env:PATH = "$npmBin;$env:PATH"
}

# Clone and install
$installDir = Join-Path $env:USERPROFILE ".cryptex"
Write-Host "Installing to: $installDir"
Remove-Item -Recurse -Force $installDir -ErrorAction SilentlyContinue
git clone https://github.com/hlsitechio/cryptexcli1.git $installDir

# Install dependencies and create global link
Set-Location (Join-Path $installDir "cryptex-cli")
Write-Host "Installing dependencies..."
npm install --no-save

# Create global link
Write-Host "Creating global link..."
npm link

Write-Host "`n✨ Installation complete! Try 'cryptex interact' to begin your magical journey."
Write-Host "Note: If 'cryptex' is not recognized in a new terminal, you may need to restart your terminal."