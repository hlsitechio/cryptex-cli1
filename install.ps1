# Cryptex Installation Script
Write-Host "🧙‍♂️ Summoning Cryptex..."

# Check for Node.js
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js found: $nodeVersion"
} catch {
    Write-Host "❌ Node.js is required but not installed!"
    Write-Host "Please install Node.js from https://nodejs.org/"
    exit 1
}

# Create temporary directory
$tempDir = Join-Path $env:TEMP "cryptex-install"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# Download and extract repository
Write-Host "📦 Downloading Cryptex..."
$repo = "hlsitechio/cryptex"
$branch = "main"
$url = "https://github.com/$repo/archive/refs/heads/$branch.zip"
$zipPath = Join-Path $tempDir "cryptex.zip"
Invoke-WebRequest -Uri $url -OutFile $zipPath

# Extract
Write-Host "📂 Extracting files..."
Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
$extractedDir = Join-Path $tempDir "cryptex-$branch"

# Install globally
Write-Host "🔮 Installing Cryptex..."
Set-Location $extractedDir
npm install
npm link cryptex-cli

# Create .env if it doesn't exist
if (-not (Test-Path .env)) {
    "CRYPTEX_GOOGLE_AI_KEY=your_sacred_key_of_power" | Out-File -FilePath .env -Encoding UTF8
    Write-Host "📜 Created .env file"
}

# Cleanup
Set-Location $env:USERPROFILE
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "✨ Installation complete! Try 'cryptex interact' to begin your magical journey!"