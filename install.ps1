# Cryptex Installation Script
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'  # Speeds up downloads significantly

Write-Host "🧙‍♂️ Summoning Cryptex..."

# Set installation directory in PowerShell modules path
$documentsPath = [Environment]::GetFolderPath('MyDocuments')
if (-not $documentsPath) {
    $documentsPath = Join-Path $env:USERPROFILE "Documents"
}

$modulesPath = Join-Path $documentsPath "WindowsPowerShell\Modules"
$installDir = Join-Path $modulesPath "Cryptex"

Write-Host "Installing to: $installDir"

# Create directories if they don't exist
New-Item -ItemType Directory -Force -Path $modulesPath | Out-Null
if (Test-Path $installDir) {
    Remove-Item -Path $installDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

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
    Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath -UseBasicParsing

    # Extract files
    Write-Host "Extracting files..."
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
    Copy-Item -Path (Join-Path $tempDir "cryptexcli1-main\*") -Destination $installDir -Recurse -Force

    # Create PowerShell module manifest
    $manifestPath = Join-Path $installDir "Cryptex.psd1"
    $manifestContent = @"
@{
    ModuleVersion = '1.0'
    GUID = 'a12345bc-1234-5678-9012-34567890abcd'
    Author = 'Cryptex Team'
    CompanyName = 'Cryptex'
    Copyright = '(c) 2025 Cryptex. All rights reserved.'
    Description = 'Cryptex CLI Tool'
    PowerShellVersion = '5.0'
    FunctionsToExport = @('Invoke-Cryptex', 'Start-CryptexInteraction', 'Set-CryptexApiKey')
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
# Cryptex PowerShell Module

# Configuration
`$script:ApiKey = `$null
`$script:ConfigFile = Join-Path `$env:USERPROFILE ".cryptex-config"

function Initialize-CryptexConfig {
    if (Test-Path `$script:ConfigFile) {
        try {
            `$config = Get-Content `$script:ConfigFile | ConvertFrom-Json
            `$script:ApiKey = `$config.ApiKey
        } catch {
            Write-Warning "Failed to load config file. You may need to set your API key again."
        }
    }
}

function Set-CryptexApiKey {
    param(
        [Parameter(Mandatory=`$true)]
        [string]`$ApiKey
    )
    
    `$config = @{
        ApiKey = `$ApiKey
    }
    
    `$config | ConvertTo-Json | Set-Content `$script:ConfigFile
    `$script:ApiKey = `$ApiKey
    Write-Host "✅ API key set successfully"
}

function Start-CryptexInteraction {
    param(
        [Parameter(Position=0)]
        [string]`$InitialPrompt
    )

    if (-not `$script:ApiKey) {
        Write-Host "⚠️ API Key not set. Please set it using:"
        Write-Host "    Set-CryptexApiKey 'your-api-key'"
        return
    }

    Write-Host "🤖 Starting Cryptex interaction..."
    Write-Host "Type 'exit' to end the session"
    Write-Host ""

    while (`$true) {
        if (`$InitialPrompt) {
            `$input = `$InitialPrompt
            `$InitialPrompt = `$null
        } else {
            Write-Host "You: " -NoNewline
            `$input = Read-Host
        }

        if (`$input -eq 'exit') {
            break
        }

        try {
            # Here we'll add the actual API call logic
            Write-Host "`nCryptex: This is a placeholder response. API integration coming soon!`n"
        } catch {
            Write-Host "❌ Error: `$_"
        }
    }
}

function Invoke-Cryptex {
    param(
        [Parameter(ValueFromRemainingArguments=`$true)]
        [string[]]`$Arguments
    )
    
    Initialize-CryptexConfig

    if (`$Arguments.Count -eq 0) {
        Write-Host "Usage: cryptex <command> [arguments]"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  interact    Start interactive mode"
        Write-Host "  setkey     Set API key"
        return
    }

    switch (`$Arguments[0]) {
        'interact' {
            Start-CryptexInteraction (`$Arguments | Select-Object -Skip 1)
        }
        'setkey' {
            if (`$Arguments.Count -lt 2) {
                Write-Host "Usage: cryptex setkey <your-api-key>"
                return
            }
            Set-CryptexApiKey `$Arguments[1]
        }
        default {
            Write-Host "Unknown command: `$(`$Arguments[0])"
        }
    }
}

# Create alias
Set-Alias -Name cryptex -Value Invoke-Cryptex

# Export members
Export-ModuleMember -Function @('Invoke-Cryptex', 'Start-CryptexInteraction', 'Set-CryptexApiKey') -Alias cryptex
"@

    Set-Content -Path $modulePath -Value $moduleContent

    Write-Host "`n✨ Installation complete!"
    Write-Host "To start using Cryptex, run:"
    Write-Host "    Import-Module Cryptex"
    Write-Host "    cryptex setkey YOUR-API-KEY"
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