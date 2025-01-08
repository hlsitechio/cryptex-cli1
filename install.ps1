# Cryptex Installation Script
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"
$ProgressPreference = 'SilentlyContinue'  # Speeds up downloads significantly

function Get-ModuleInstallPath {
    # Get PowerShell module paths
    $paths = @(
        # First try OneDrive path
        [System.IO.Path]::Combine($env:USERPROFILE, "OneDrive", "Documents", "WindowsPowerShell", "Modules"),
        # Then regular Documents
        [System.IO.Path]::Combine($env:USERPROFILE, "Documents", "WindowsPowerShell", "Modules"),
        # Finally system path
        [System.IO.Path]::Combine($env:ProgramFiles, "WindowsPowerShell", "Modules")
    )

    foreach ($path in $paths) {
        $parentPath = Split-Path $path -Parent
        if (Test-Path $parentPath) {
            Write-Verbose "Found valid module path: $path"
            if (-not (Test-Path $path)) {
                Write-Verbose "Creating module directory: $path"
                New-Item -ItemType Directory -Path $path -Force | Out-Null
            }
            return $path
        }
    }

    throw "Could not find or create a valid PowerShell module path"
}

Write-Host "🧙‍♂️ Summoning Cryptex..."

# Get module installation path
$modulesRoot = Get-ModuleInstallPath
$modulePath = Join-Path $modulesRoot "Cryptex"
Write-Host "Installing to: $modulePath"

# Remove existing installation if present
if (Test-Path $modulePath) {
    Write-Verbose "Removing existing Cryptex installation"
    Remove-Item -Path $modulePath -Recurse -Force
    Write-Verbose "Removed existing installation"
}

# Create module directory
Write-Verbose "Creating module directory"
New-Item -ItemType Directory -Path $modulePath -Force | Out-Null

try {
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
        RootModule = 'Cryptex.psm1'
        FunctionsToExport = @('Invoke-Cryptex')
        CmdletsToExport = @()
        VariablesToExport = '*'
        AliasesToExport = @('cryptex')
    }
    
    Write-Verbose "Creating module manifest: $manifestPath"
    New-ModuleManifest -Path $manifestPath @manifest
    Write-Verbose "Module manifest created successfully"

    # Create module script with UTF-8 encoding
    $moduleContent = @'
# Cryptex PowerShell Module
$ErrorActionPreference = 'Stop'

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
        try {
            $config = Get-Content $script:ConfigFile | ConvertFrom-Json
            $script:ApiKey = $config.ApiKey
        } catch {
            Write-Warning "Failed to load config file. You may need to set your API key again."
        }
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
        
        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body -ContentType 'application/json'
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

function Set-CryptexApiKey {
    param(
        [Parameter(Mandatory=$true, ParameterSetName='ClearText')]
        [string]$ApiKey,
        
        [Parameter(Mandatory=$true, ParameterSetName='Secure')]
        [switch]$Prompt
    )
    
    if ($Prompt) {
        Write-Host "Enter your Google AI API key (input will be hidden):"
        $secureKey = Read-Host -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
        $ApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    }
    
    Write-Host "Validating API key..."
    if (Test-CryptexApiKey -ApiKey $ApiKey) {
        $config = @{
            ApiKey = $ApiKey
        }
        
        $config | ConvertTo-Json | Set-Content $script:ConfigFile -Force
        $script:ApiKey = $ApiKey
        Write-Host "✅ API key validated and saved successfully"
        
        # Clear sensitive data
        if ($Prompt) {
            Remove-Variable -Name ApiKey, secureKey
        }
    } else {
        Write-Host "❌ Invalid API key. Please check your key and try again."
        return
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
        Write-Host "    cryptex setkey -Prompt"
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
            
            $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Headers $headers -Body $body -ContentType 'application/json'

            # Stream the response
            if ($response.candidates -and $response.candidates[0].content.parts) {
                $response.candidates[0].content.parts[0].text -split "`n" | ForEach-Object {
                    $line = $_.Trim()
                    if ($line) {
                        Write-Host $line
                        Start-Sleep -Milliseconds 50
                    }
                }
                Write-Host ""
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
        Write-Host "  setkey -Prompt     Set API key securely"
        return
    }

    switch ($Arguments[0]) {
        'interact' {
            Start-CryptexInteraction ($Arguments | Select-Object -Skip 1)
        }
        'setkey' {
            if ($Arguments.Count -eq 1 -or $Arguments[1] -eq '-Prompt') {
                Set-CryptexApiKey -Prompt
            } elseif ($Arguments.Count -gt 1) {
                Set-CryptexApiKey $Arguments[1]
            } else {
                Write-Host "Usage: cryptex setkey <your-api-key>"
                Write-Host "   or: cryptex setkey -Prompt"
            }
        }
        default {
            Write-Host "Unknown command: $($Arguments[0])"
        }
    }
}

# Create alias for the module
Set-Alias -Name cryptex -Value Invoke-Cryptex -Scope Global

# Export functions and alias
Export-ModuleMember -Function Invoke-Cryptex -Alias cryptex
'@

    $moduleScriptPath = Join-Path $modulePath "Cryptex.psm1"
    Write-Verbose "Creating module script: $moduleScriptPath"
    $utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($moduleScriptPath, $moduleContent, $utf8NoBomEncoding)
    Write-Verbose "Module script created successfully"

    Write-Host "`n✨ Installation complete!"
    Write-Host "Would you like to set up your API key now? (y/n)" -NoNewline
    $response = Read-Host
    
    if ($response -eq 'y') {
        Write-Host "`nEnter your Google AI API key (input will be hidden):"
        $secureKey = Read-Host -AsSecureString
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
        $apiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        
        # Import module and set key
        Import-Module Cryptex -Force
        Set-CryptexApiKey $apiKey

        # Clear sensitive data from memory
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        Remove-Variable -Name apiKey, secureKey, BSTR
        
        Write-Host "`nYou can now use 'cryptex interact' to start using Cryptex!"
    } else {
        Write-Host "`nTo start using Cryptex later, run:"
        Write-Host "    Import-Module Cryptex"
        Write-Host "    cryptex setkey -Prompt"
        Write-Host "    cryptex interact"
    }

    Write-Host "`nNote: The module will be automatically imported in new PowerShell sessions."

} catch {
    Write-Error "Installation failed: $_"
    Write-Error $_.ScriptStackTrace
    Exit 1
} finally {
    # Cleanup temp directory if it exists
    if (Test-Path $tempDir) {
        Write-Verbose "Cleaning up temp directory: $tempDir"
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}