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

try {
    # Create temp directory for download
    $tempDir = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName())
    Write-Verbose "Creating temp directory: $tempDir"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

    # Download the repository
    Write-Host "Downloading Cryptex..."
    $zipFile = Join-Path $tempDir "cryptex.zip"
    $downloadUrl = "https://github.com/hlsitechio/cryptexcli1/archive/refs/heads/main.zip"
    
    Write-Verbose "Downloading from: $downloadUrl"
    Write-Verbose "Saving to: $zipFile"
    
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
    Write-Verbose "Download completed successfully"

    # Extract the zip
    Write-Host "Extracting files..."
    Write-Verbose "Extracting zip to: $tempDir"
    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
    Write-Verbose "Extraction completed"
    
    # Create module directory if it doesn't exist
    if (-not (Test-Path $modulePath)) {
        Write-Verbose "Creating module directory: $modulePath"
        New-Item -ItemType Directory -Force -Path $modulePath | Out-Null
    }

    # Create module files
    Write-Verbose "Creating module files in: $modulePath"
    
    # Create module manifest
    $manifestPath = Join-Path $modulePath "Cryptex.psd1"
    $manifest = @{
        ModuleVersion = '1.0.0'
        GUID = 'b7c3a04d-d3b0-4c1d-8b89-9b5d3e4e4e4e'
        Author = 'HLSitechIO'
        CompanyName = 'HLSitechIO'
        Copyright = '(c) 2025 HLSitechIO. All rights reserved.'
        Description = 'Cryptex CLI for Google Gemini AI'
        PowerShellVersion = '5.1'
        FunctionsToExport = @('Invoke-Cryptex')
        CmdletsToExport = @()
        VariablesToExport = '*'
        AliasesToExport = @()
        RootModule = 'Cryptex.psm1'
    }
    New-ModuleManifest -Path $manifestPath @manifest
    Write-Verbose "Module manifest created successfully"

    # Create module script
    $moduleContent = @'
# Configuration
$script:ApiKey = $null
$script:ConfigFile = Join-Path $env:USERPROFILE ".cryptex-config"
$script:ApiEndpoint = "https://generativelanguage.googleapis.com"
$script:ApiVersion = "v1beta"
$script:DefaultModel = "gemini-2.0-flash-exp"
$script:DefaultMaxTokens = 1000
$script:DefaultTemperature = 0.7

function Initialize-CryptexConfig {
    if (Test-Path $script:ConfigFile) {
        $config = Get-Content $script:ConfigFile | ConvertFrom-Json
        $script:ApiKey = $config.ApiKey
    }
}

function Format-CryptexResponse {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Response
    )
    
    $Response -split "`n" | ForEach-Object {
        $line = $_.Trim()
        if ($line) {
            Write-Host $line
            Start-Sleep -Milliseconds 50
        }
    }
    Write-Host ""
}

function Set-CryptexApiKey {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ApiKey
    )
    
    Write-Host "Validating API key..."
    if (Test-CryptexApiKey -ApiKey $ApiKey) {
        $config = @{
            ApiKey = $ApiKey
        }
        
        $config | ConvertTo-Json | Set-Content $script:ConfigFile -Force
        $script:ApiKey = $ApiKey
        Write-Host "✅ API key validated and saved successfully"
    } else {
        Write-Host "❌ Invalid API key. Please check your key and try again."
        return
    }
}

function Test-CryptexApiKey {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ApiKey
    )

    try {
        $headers = @{
            'Content-Type' = 'application/json'
        }

        $body = @{
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

        $apiUrl = "$($script:ApiEndpoint)/$($script:ApiVersion)/models/$($script:DefaultModel):generateContent?key=$ApiKey"
        Write-Verbose "Testing API connection to: $apiUrl"
        
        $response = Invoke-RestMethod -Uri $apiUrl `
            -Method Post `
            -Headers $headers `
            -Body $body `
            -ContentType 'application/json'

        return $true
    } catch {
        $errorMessage = ""
        if ($_.ErrorDetails.Message) {
            try {
                $errorJson = $_.ErrorDetails.Message | ConvertFrom-Json
                $errorMessage = $errorJson.error.message
            } catch {
                $errorMessage = $_.ErrorDetails.Message
            }
        } else {
            $errorMessage = $_.Exception.Message
        }
        Write-Warning "API Key validation failed: $errorMessage"
        return $false
    }
}

function Start-CryptexInteraction {
    param(
        [Parameter(Position=0)]
        [string]$InitialPrompt,
        [Parameter(Mandatory=$false)]
        [string]$Model = $script:DefaultModel,
        [Parameter(Mandatory=$false)]
        [int]$MaxTokens = $script:DefaultMaxTokens,
        [Parameter(Mandatory=$false)]
        [double]$Temperature = $script:DefaultTemperature
    )

    if (-not $script:ApiKey) {
        Write-Host "⚠️ API Key not set. Please set it using:"
        Write-Host "    Set-CryptexApiKey 'your-api-key'"
        return
    }

    Write-Host "🤖 Starting Cryptex interaction..."
    Write-Host "Using model: $Model"
    Write-Host "Type 'exit' to end the session"
    Write-Host ""

    while ($true) {
        if ($InitialPrompt) {
            $input = $InitialPrompt
            $InitialPrompt = $null
        } else {
            Write-Host "You: " -NoNewline
            $input = Read-Host
        }

        if ($input -eq 'exit') {
            break
        }

        try {
            # Prepare API request
            $headers = @{
                'Content-Type' = 'application/json'
            }

            $body = @{
                'contents' = @(
                    @{
                        'parts' = @(
                            @{
                                'text' = $input
                            }
                        )
                    }
                )
            } | ConvertTo-Json -Depth 10

            # Make API call
            Write-Host "`nCryptex: " -NoNewline
            $apiUrl = "$($script:ApiEndpoint)/$($script:ApiVersion)/models/$Model`:generateContent?key=$($script:ApiKey)"
            Write-Verbose "Sending request to: $apiUrl"
            
            $response = Invoke-RestMethod -Uri $apiUrl `
                -Method Post `
                -Headers $headers `
                -Body $body `
                -ContentType 'application/json'

            # Stream the response
            if ($response.candidates -and $response.candidates[0].content.parts) {
                Format-CryptexResponse -Response $response.candidates[0].content.parts[0].text
            } else {
                Write-Host "No response generated."
            }
        } catch {
            $errorMessage = ""
            if ($_.ErrorDetails.Message) {
                try {
                    $errorJson = $_.ErrorDetails.Message | ConvertFrom-Json
                    $errorMessage = $errorJson.error.message
                } catch {
                    $errorMessage = $_.ErrorDetails.Message
                }
            } else {
                $errorMessage = $_.Exception.Message
            }
            Write-Host "❌ Error: $errorMessage"
        }
    }
}

function Invoke-Cryptex {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Arguments
    )
    
    Initialize-CryptexConfig

    if ($Arguments.Count -eq 0) {
        Write-Host "Usage: cryptex <command> [arguments]"
        Write-Host ""
        Write-Host "Commands:"
        Write-Host "  interact [prompt]   Start interactive mode"
        Write-Host "  setkey <key>       Set API key"
        Write-Host "  config             Show current configuration"
        Write-Host "  config set         Set configuration options"
        return
    }

    switch ($Arguments[0]) {
        'interact' {
            Start-CryptexInteraction ($Arguments | Select-Object -Skip 1)
        }
        'setkey' {
            if ($Arguments.Count -lt 2) {
                Write-Host "Usage: cryptex setkey <your-api-key>"
                return
            }
            Set-CryptexApiKey $Arguments[1]
        }
        'config' {
            if ($Arguments.Count -gt 1 -and $Arguments[1] -eq 'set') {
                $params = @{}
                for ($i = 2; $i -lt $Arguments.Count; $i += 2) {
                    if ($i + 1 -lt $Arguments.Count) {
                        $key = $Arguments[$i]
                        $value = $Arguments[$i + 1]
                        $params[$key] = $value
                    }
                }
                Set-CryptexConfig @params
            } else {
                $config = Get-CryptexConfig
                $config | Format-List
            }
        }
        default {
            Write-Host "Unknown command: $($Arguments[0])"
        }
    }
}

# Create alias for the module
Set-Alias -Name cryptex -Value Invoke-Cryptex -Scope Global

# Export functions
Export-ModuleMember -Function Invoke-Cryptex -Alias cryptex
'@

    $moduleScriptPath = Join-Path $modulePath "Cryptex.psm1"
    Set-Content -Path $moduleScriptPath -Value $moduleContent
    Write-Verbose "Module script created successfully"

    Write-Host "`n✨ Installation complete!"
    Write-Host "To start using Cryptex, run:"
    Write-Host "    Import-Module Cryptex"
    Write-Host "    cryptex setkey YOUR-API-KEY"
    Write-Host "    cryptex interact"
    Write-Host "`nNote: The module will be automatically imported in new PowerShell sessions."

} catch {
    Write-Error "Installation failed: $_"
    Exit 1
} finally {
    if (Test-Path $tempDir) {
        Write-Verbose "Cleaning up temp directory: $tempDir"
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}