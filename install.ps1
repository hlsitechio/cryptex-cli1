# Cryptex Installation Script
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'  # Speeds up downloads significantly

Write-Host "🧙‍♂️ Summoning Cryptex..."

# Check for required commands
function Test-Command($cmd) {
    if (!(Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Error: '$cmd' not found. Please install it first."
        Exit 1
    }
}

Test-Command "node"

# Set installation directory in PowerShell modules path
$modulesPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "WindowsPowerShell\Modules"
$installDir = Join-Path $modulesPath "Cryptex"
Write-Host "Installing to: $installDir"

# Create temp directory for download
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

try {
    # Download repository as zip
    Write-Host "Downloading Cryptex..."
    $repoUrl = "https://github.com/hlsitechio/cryptexcli1/archive/refs/heads/main.zip"
    $zipPath = Join-Path $tempDir "cryptex.zip"
    
    # Use TLS 1.2 for security
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath

    # Remove existing installation if present
    Remove-Item -Recurse -Force $installDir -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null

    # Extract files
    Write-Host "Extracting files..."
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
    Copy-Item -Path (Join-Path $tempDir "cryptexcli1-main\*") -Destination $installDir -Recurse -Force

    # Create PowerShell module manifest
    $manifestPath = Join-Path $installDir "Cryptex.psd1"
    $cryptexScript = Join-Path $installDir "bin\cryptex.js"

    $manifestContent = @"
@{
    ModuleVersion = '1.0'
    GUID = 'a12345bc-1234-5678-9012-34567890abcd'
    Author = 'Cryptex Team'
    CompanyName = 'Cryptex'
    Copyright = '(c) 2025 Cryptex. All rights reserved.'
    Description = 'Cryptex CLI Tool'
    PowerShellVersion = '5.0'
    FunctionsToExport = @('Invoke-Cryptex')
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @('cryptex')
    RootModule = 'Cryptex.psm1'
}
"@

    Set-Content -Path $manifestPath -Value $manifestContent

    # Create PowerShell module script
    $modulePath = Join-Path $installDir "Cryptex.psm1"
    $moduleContent = @"
function Invoke-Cryptex {
    param(
        [Parameter(ValueFromRemainingArguments=`$true)]
        [string[]]`$Arguments
    )
    
    `$cryptexPath = Join-Path `$PSScriptRoot 'bin\cryptex.js'
    & node `$cryptexPath @Arguments
}

Set-Alias -Name cryptex -Value Invoke-Cryptex
Export-ModuleMember -Function Invoke-Cryptex -Alias cryptex
"@

    Set-Content -Path $modulePath -Value $moduleContent

    Write-Host "`n✨ Installation complete!"
    Write-Host "To start using Cryptex, run:"
    Write-Host "    Import-Module Cryptex"
    Write-Host "    cryptex interact"
    Write-Host "`nNote: The module will be automatically imported in new PowerShell sessions."

} catch {
    Write-Host "❌ Error during installation: $_"
    Exit 1
} finally {
    # Cleanup
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}