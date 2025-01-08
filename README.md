# Cryptex CLI

A PowerShell-based CLI tool for interacting with Google's Gemini AI.

## System Requirements

### Minimum Requirements
- Windows 10 2004 (build 19041) or later
- One of the following PowerShell versions:
  - PowerShell 7.x (recommended)
  - Windows PowerShell 5.1

### Required Software
1. **Windows Terminal** (Recommended)
   - Install from [Microsoft Store](https://aka.ms/terminal) (recommended)
   - Or download from [GitHub Releases](https://github.com/microsoft/terminal/releases)

2. **PowerShell 7**
   - Install from [Microsoft Store](https://aka.ms/powershell) (recommended)
   - Or download from [GitHub Releases](https://github.com/PowerShell/PowerShell/releases)

3. **Visual C++ Runtime**
   - Download [Visual C++ Redistributable 2015-2022](https://aka.ms/vs/17/release/vc_redist.x64.exe)
   - Required for various system components

4. **.NET Runtime**
   - Download [.NET 7.0 Runtime](https://dotnet.microsoft.com/download/dotnet/7.0/runtime)
   - Required for PowerShell 7 and some Cryptex features

### Optional Software
1. **Git** (for developers)
   - Download from [Git for Windows](https://gitforwindows.org/)
   - Useful for getting updates and contributing

2. **Visual Studio Code** (recommended for development)
   - Download from [VS Code](https://code.visualstudio.com/)
   - Recommended extensions:
     - PowerShell Extension
     - Git Extension

## Installation Guide

### Method 1: Windows Terminal + PowerShell 7 (Recommended)

1. **Install Prerequisites**
   ```powershell
   # Using winget (Windows Package Manager)
   winget install Microsoft.WindowsTerminal
   winget install Microsoft.PowerShell
   winget install Microsoft.VCRedist.2015+.x64
   winget install Microsoft.DotNet.Runtime.7
   ```
   
   Or install manually:
   - Install [Windows Terminal](https://aka.ms/terminal)
   - Install [PowerShell 7](https://aka.ms/powershell)
   - Install [Visual C++ Runtime](https://aka.ms/vs/17/release/vc_redist.x64.exe)
   - Install [.NET 7.0 Runtime](https://dotnet.microsoft.com/download/dotnet/7.0/runtime)
   
2. **Open Windows Terminal**
   - Press Win + X and select "Windows Terminal"
   - Click the dropdown arrow and select "PowerShell" (not "Windows PowerShell")
   - Verify you're using PowerShell 7 by running:
     ```powershell
     $PSVersionTable.PSVersion
     ```
   - You should see version 7.x.x

3. **Create Installation Directory**
   - Open File Explorer
   - Navigate to your C: drive
   - Create a new folder called `cryptex`

4. **Download and Extract Files**
   - Click this link to download: [Download Cryptex](https://github.com/hlsitechio/cryptex-cli1/archive/refs/heads/main.zip)
   - When the download completes:
     - Open your Downloads folder
     - Right-click the downloaded ZIP file (cryptex-cli1-main.zip)
     - Select "Extract All..."
     - In the Extract window, browse to `C:\cryptex`
     - Click "Extract"
   - You should now have the files in `C:\cryptex\cryptex-cli1-main`

5. **Install Cryptex**
   - In Windows Terminal with PowerShell 7, run:
     ```powershell
     cd C:\cryptex\cryptex-cli1-main
     .\install.ps1
     ```
   - Choose where to install:
     - For PowerShell 7: Choose "PowerShell 7 User Documents"
     - For PowerShell 5.1: Choose "PowerShell 5.1 User Documents"
   - When asked about the API key:
     - Choose 'y' if you have one
     - Choose 'n' if you don't have one yet

### Method 2: Classic PowerShell (Legacy)

If you prefer using classic Windows PowerShell 5.1:

1. Press Win + X and select "Windows PowerShell"
2. Follow the same steps as above, but when installing:
   - Choose "PowerShell 5.1 User Documents" as the installation location

### Method 3: Developer Installation (via Git)

For developers who want to contribute or get the latest updates:

1. Install additional tools:
   ```powershell
   winget install Git.Git
   winget install Microsoft.VisualStudioCode
   ```

2. Clone and install:
   ```powershell
   git clone https://github.com/hlsitechio/cryptex-cli1.git
   cd cryptex-cli1
   .\install.ps1
   ```

## Verifying Installation

After installation:
1. Close all PowerShell/Terminal windows
2. Open a new Windows Terminal or PowerShell
3. Run the verification command:
   ```powershell
   cryptex --version
   cryptex interact "Hello!"
   ```

## Troubleshooting

### Prerequisites Check
Run this script to check if all prerequisites are installed:
```powershell
$checks = @{
    "Windows Terminal" = Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"
    "PowerShell 7" = $PSVersionTable.PSVersion.Major -ge 7
    "Visual C++ Runtime" = Test-Path "C:\Windows\System32\vcruntime140.dll"
    ".NET Runtime" = [System.Runtime.InteropServices.RuntimeInformation]::FrameworkDescription -like "*7.0*"
}

foreach ($check in $checks.GetEnumerator()) {
    Write-Host "$($check.Key): $($check.Value)"
}
```

## Getting Your API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your new API key

## Setting Up Your API Key

1. Open a new PowerShell window
2. Run:
   ```powershell
   cryptex setkey -Prompt
   ```
3. Paste your API key when prompted (the input will be hidden)

## Using Cryptex

Start an interactive chat:
```powershell
cryptex interact
```

Ask a single question:
```powershell
cryptex interact "What is the capital of France?"
```

## Uninstalling Cryptex

You have two ways to uninstall Cryptex:

1. **Using the command (Recommended)**
   ```powershell
   cryptex uninstall
   ```

2. **Manual uninstallation**
   - Open PowerShell
   - Navigate to your Cryptex installation:
     ```powershell
     cd C:\cryptex\cryptex-cli1-main
     ```
   - Run the uninstall script:
     ```powershell
     .\uninstall.ps1
     ```

The uninstaller will:
- Remove all Cryptex module files
- Delete your configuration file (including API key)
- Clean up any temporary files

## Need Help?

- Check our [Issues page](https://github.com/hlsitechio/cryptex-cli1/issues)
- Create a new issue if you're still stuck
- Contact support at [support@hlsitech.io](mailto:support@hlsitech.io)