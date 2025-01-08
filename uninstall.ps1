# PowerShell Module Uninstallation Script
[CmdletBinding()]
param()

# Set strict error handling
$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'

function Remove-CryptexInstallation {
    $paths = @(
        [System.IO.Path]::Combine($env:USERPROFILE, "Documents", "WindowsPowerShell", "Modules", "Cryptex"),
        [System.IO.Path]::Combine($env:USERPROFILE, "OneDrive", "Documents", "WindowsPowerShell", "Modules", "Cryptex"),
        [System.IO.Path]::Combine($env:ProgramFiles, "WindowsPowerShell", "Modules", "Cryptex")
    )

    $configFile = Join-Path $env:USERPROFILE ".cryptex-config"
    
    Write-Host "`nSearching for Cryptex installations..."
    $found = $false

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Write-Host "Found installation at: $path"
            $found = $true
        }
    }

    if (Test-Path $configFile) {
        Write-Host "Found configuration file at: $configFile"
        $found = $true
    }

    if (-not $found) {
        Write-Host "No Cryptex installations found."
        return
    }

    Write-Host "`nWould you like to remove all Cryptex installations and configuration? (y/n): " -NoNewline
    $response = Read-Host

    if ($response -ne 'y') {
        Write-Host "Uninstallation cancelled."
        return
    }

    # Remove module from memory if loaded
    if (Get-Module Cryptex) {
        Write-Verbose "Removing Cryptex module from current session"
        Remove-Module Cryptex -Force
    }

    # Remove installations
    foreach ($path in $paths) {
        if (Test-Path $path) {
            Write-Verbose "Removing installation: $path"
            try {
                Remove-Item -Path $path -Recurse -Force
                Write-Host "Removed: $path"
            } catch {
                Write-Warning "Failed to remove $path : $_"
            }
        }
    }

    # Remove config file
    if (Test-Path $configFile) {
        Write-Verbose "Removing configuration file"
        try {
            Remove-Item -Path $configFile -Force
            Write-Host "Removed configuration file: $configFile"
        } catch {
            Write-Warning "Failed to remove configuration file: $_"
        }
    }

    Write-Host "`nUninstallation complete!"
    Write-Host "To reinstall Cryptex in the future, run install.ps1"
}

try {
    Remove-CryptexInstallation
} catch {
    Write-Error "Uninstallation failed: $_"
    Write-Error $_.ScriptStackTrace
    Exit 1
}
