# Cryptex Installation Script
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"
$ProgressPreference = 'SilentlyContinue'  # Speeds up downloads significantly

Write-Host "🧙‍♂️ Summoning Cryptex..."

# Set installation directory in PowerShell modules path
$modulesPath = $null

# Try different possible locations for PowerShell modules
$possiblePaths = @(
    # User profile Documents
    (Join-Path $env:USERPROFILE "Documents"),
    # Standard Documents folder
    [Environment]::GetFolderPath('MyDocuments'),
    # Direct user profile as fallback
    $env:USERPROFILE
)

Write-Verbose "Searching for valid installation path..."
foreach ($basePath in $possiblePaths) {
    Write-Verbose "Checking path: $basePath"
    if (Test-Path $basePath) {
        Write-Verbose "Found valid base path: $basePath"
        $modulesPath = Join-Path $basePath "WindowsPowerShell\Modules"
        break
    }
}

if (-not $modulesPath) {
    Write-Verbose "No existing paths found, defaulting to user profile"
    $modulesPath = Join-Path $env:USERPROFILE "Documents\WindowsPowerShell\Modules"
}

$installDir = Join-Path $modulesPath "Cryptex"

Write-Host "Installing to: $installDir"

# Create directories if they don't exist
Write-Verbose "Creating module directory: $modulesPath"
try {
    if (-not (Test-Path $modulesPath)) {
        New-Item -ItemType Directory -Force -Path $modulesPath | Out-Null
        Write-Verbose "Created modules directory successfully"
    }

    Write-Verbose "Removing existing Cryptex installation if present"
    if (Test-Path $installDir) {
        Remove-Item -Path $installDir -Recurse -Force
        Write-Verbose "Removed existing installation"
    }

    Write-Verbose "Creating Cryptex installation directory"
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null
    Write-Verbose "Created installation directory successfully"
} catch {
    Write-Error "Failed to create directories: $_"
    Exit 1
}

# Create temp directory for download
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
Write-Verbose "Creating temp directory: $tempDir"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

try {
    # Download repository as zip
    Write-Host "Downloading Cryptex..."
    $repoUrl = "https://github.com/hlsitechio/cryptexcli1/archive/refs/heads/main.zip"
    $zipPath = Join-Path $tempDir "cryptex.zip"
    
    Write-Verbose "Downloading from: $repoUrl"
    Write-Verbose "Saving to: $zipPath"
    
    # Use TLS 1.2 for security
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $repoUrl -OutFile $zipPath -UseBasicParsing
    Write-Verbose "Download completed successfully"

    # Extract files
    Write-Host "Extracting files..."
    Write-Verbose "Extracting zip to: $tempDir"
    Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
    Write-Verbose "Extraction completed"
    
    # Copy files
    $sourceDir = Join-Path $tempDir "cryptexcli1-main"
    Write-Verbose "Copying files from: $sourceDir to: $installDir"

    # Create module files directly
    $manifestPath = Join-Path $installDir "Cryptex.psd1"
    $modulePath = Join-Path $installDir "Cryptex.psm1"

    Write-Verbose "Creating module manifest: $manifestPath"

    # Create PowerShell module manifest
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
    Set-Content -Path $manifestPath -Value $manifestContent -Force
    Write-Verbose "Module manifest created successfully"

    # Create PowerShell module script
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

function Test-CryptexApiKey {
    param(
        [Parameter(Mandatory=`$true)]
        [string]`$ApiKey
    )

    try {
        `$headers = @{
            'Content-Type' = 'application/json'
            'Authorization' = "Bearer `$ApiKey"
        }

        # Make a small test request
        `$body = @{
            'prompt' = 'test'
            'max_tokens' = 1
            'temperature' = 0.7
            'model' = 'gpt-4'
        } | ConvertTo-Json

        `$response = Invoke-RestMethod -Uri 'https://api.cryptex.ai/v1/chat/completions' `
            -Method Post `
            -Headers `$headers `
            -Body `$body `
            -ContentType 'application/json'

        return `$true
    } catch {
        `$errorDetails = `$_.ErrorDetails.Message
        try {
            `$errorJson = `$errorDetails | ConvertFrom-Json
            Write-Warning "API Key validation failed: `$(`$errorJson.error.message)"
        } catch {
            Write-Warning "API Key validation failed: `$(`$_)"
        }
        return `$false
    }
}

function Format-CryptexResponse {
    param(
        [Parameter(Mandatory=`$true)]
        [string]`$Response
    )

    `$Response -split "`n" | ForEach-Object {
        `$line = `$_.Trim()
        if (`$line) {
            Write-Host `$line
            Start-Sleep -Milliseconds 50
        }
    }
    Write-Host ""
}

function Set-CryptexApiKey {
    param(
        [Parameter(Mandatory=`$true)]
        [string]`$ApiKey
    )
    
    Write-Host "Validating API key..."
    if (Test-CryptexApiKey -ApiKey `$ApiKey) {
        `$config = @{
            ApiKey = `$ApiKey
        }
        
        `$config | ConvertTo-Json | Set-Content `$script:ConfigFile -Force
        `$script:ApiKey = `$ApiKey
        Write-Host "✅ API key validated and saved successfully"
    } else {
        Write-Host "❌ Invalid API key. Please check your key and try again."
        return
    }
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
            # Prepare API request
            `$headers = @{
                'Content-Type' = 'application/json'
                'Authorization' = "Bearer `$(`$script:ApiKey)"
            }

            `$body = @{
                'prompt' = `$input
                'max_tokens' = 1000
                'temperature' = 0.7
                'model' = 'gpt-4'  # or whatever model you're using
            } | ConvertTo-Json

            # Make API call
            Write-Host "`nCryptex: " -NoNewline
            `$response = Invoke-RestMethod -Uri 'https://api.cryptex.ai/v1/chat/completions' `
                -Method Post `
                -Headers `$headers `
                -Body `$body `
                -ContentType 'application/json'

            # Stream the response
            Format-CryptexResponse -Response `$response.choices[0].message.content
        } catch {
            `$errorDetails = `$_.ErrorDetails.Message
            try {
                `$errorJson = `$errorDetails | ConvertFrom-Json
                Write-Host "❌ Error: `$(`$errorJson.error.message)"
            } catch {
                Write-Host "❌ Error: `$(`$_)"
            }
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

    Set-Content -Path $modulePath -Value $moduleContent -Force
    Write-Verbose "Module script created successfully"

    Write-Host "`n✨ Installation complete!"
    Write-Host "To start using Cryptex, run:"
    Write-Host "    Import-Module Cryptex"
    Write-Host "    cryptex setkey YOUR-API-KEY"
    Write-Host "    cryptex interact"
    Write-Host "`nNote: The module will be automatically imported in new PowerShell sessions."

} catch {
    Write-Error "Installation failed: $_"
    Write-Verbose "Stack trace: $($_.ScriptStackTrace)"
    Exit 1
} finally {
    # Cleanup
    if (Test-Path $tempDir) {
        Write-Verbose "Cleaning up temp directory: $tempDir"
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}