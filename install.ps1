# Cryptex Installation Script
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"
$ProgressPreference = 'SilentlyContinue'  # Speeds up downloads significantly

function Get-ModuleInstallPath {
    $paths = @(
        # Check OneDrive Documents first
        [System.IO.Path]::Combine($env:USERPROFILE, "OneDrive", "Documents", "WindowsPowerShell", "Modules"),
        # Then regular Documents
        [System.IO.Path]::Combine($env:USERPROFILE, "Documents", "WindowsPowerShell", "Modules"),
        # Finally, check system-wide location
        [System.IO.Path]::Combine($env:ProgramFiles, "WindowsPowerShell", "Modules")
    )

    foreach ($path in $paths) {
        if (Test-Path ([System.IO.Path]::GetDirectoryName($path))) {
            Write-Verbose "Found valid module path: $path"
            return $path
        }
    }

    # Default to OneDrive path and create if necessary
    $defaultPath = $paths[0]
    Write-Verbose "Using default module path: $defaultPath"
    return $defaultPath
}

$modulesRoot = Get-ModuleInstallPath
$modulePath = Join-Path $modulesRoot "Cryptex"

Write-Host "🧙‍♂️ Summoning Cryptex..."
Write-Verbose "Installing to: $modulePath"

# Create the modules directory if it doesn't exist
if (-not (Test-Path $modulesRoot)) {
    Write-Verbose "Creating module directory: $modulesRoot"
    New-Item -ItemType Directory -Path $modulesRoot -Force | Out-Null
}

# Remove existing installation if present
if (Test-Path $modulePath) {
    Write-Verbose "Removing existing Cryptex installation"
    Remove-Item -Path $modulePath -Recurse -Force
    Write-Verbose "Removed existing installation"
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
    Write-Verbose "Copying files from: $sourceDir to: $modulePath"

    # Create module files directly
    $manifestPath = Join-Path $modulePath "Cryptex.psd1"
    $modulePath = Join-Path $modulePath "Cryptex.psm1"

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
`$script:ApiEndpoint = "https://generativelanguage.googleapis.com"
`$script:ApiVersion = "v1beta"
`$script:DefaultModel = "gemini-2.0-flash-exp"
`$script:DefaultMaxTokens = 1000
`$script:DefaultTemperature = 0.7

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
        }

        # Make a small test request
        `$body = @{
            'contents' = @(
                @{
                    'parts' = @(
                        @{
                            'text' = "test"
                        }
                    )
                }
            )
        } | ConvertTo-Json -Depth 10

        `$apiUrl = "`$(`$script:ApiEndpoint)/`$(`$script:ApiVersion)/models/`$(`$script:DefaultModel):generateContent?key=`$ApiKey"
        Write-Verbose "Testing API connection to: `$apiUrl"
        
        `$response = Invoke-RestMethod -Uri `$apiUrl `
            -Method Post `
            -Headers `$headers `
            -Body `$body `
            -ContentType 'application/json'

        return `$true
    } catch {
        `$errorMessage = ""
        if (`$_.ErrorDetails.Message) {
            try {
                `$errorJson = `$_.ErrorDetails.Message | ConvertFrom-Json
                `$errorMessage = `$errorJson.error.message
            } catch {
                `$errorMessage = `$_.ErrorDetails.Message
            }
        } else {
            `$errorMessage = `$_.Exception.Message
        }
        Write-Warning "API Key validation failed: `$errorMessage"
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
        [string]`$InitialPrompt,
        [Parameter(Mandatory=`$false)]
        [string]`$Model = `$script:DefaultModel,
        [Parameter(Mandatory=`$false)]
        [int]`$MaxTokens = `$script:DefaultMaxTokens,
        [Parameter(Mandatory=`$false)]
        [double]`$Temperature = `$script:DefaultTemperature
    )

    if (-not `$script:ApiKey) {
        Write-Host "⚠️ API Key not set. Please set it using:"
        Write-Host "    Set-CryptexApiKey 'your-api-key'"
        return
    }

    Write-Host "🤖 Starting Cryptex interaction..."
    Write-Host "Using model: `$Model"
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
            }

            `$body = @{
                'contents' = @(
                    @{
                        'parts' = @(
                            @{
                                'text' = `$input
                            }
                        )
                    }
                )
            } | ConvertTo-Json -Depth 10

            # Make API call
            Write-Host "`nCryptex: " -NoNewline
            `$apiUrl = "`$(`$script:ApiEndpoint)/`$(`$script:ApiVersion)/models/`$Model`:generateContent?key=`$(`$script:ApiKey)"
            Write-Verbose "Sending request to: `$apiUrl"
            
            `$response = Invoke-RestMethod -Uri `$apiUrl `
                -Method Post `
                -Headers `$headers `
                -Body `$body `
                -ContentType 'application/json'

            # Stream the response
            if (`$response.candidates -and `$response.candidates[0].content.parts) {
                Format-CryptexResponse -Response `$response.candidates[0].content.parts[0].text
            } else {
                Write-Host "No response generated."
            }
        } catch {
            `$errorMessage = ""
            if (`$_.ErrorDetails.Message) {
                try {
                    `$errorJson = `$_.ErrorDetails.Message | ConvertFrom-Json
                    `$errorMessage = `$errorJson.error.message
                } catch {
                    `$errorMessage = `$_.ErrorDetails.Message
                }
            } else {
                `$errorMessage = `$_.Exception.Message
            }
            Write-Host "❌ Error: `$errorMessage"
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