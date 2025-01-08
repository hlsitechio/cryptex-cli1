# Cryptex CLI

A PowerShell-based CLI tool for interacting with Google's Gemini AI.

## Step-by-Step Installation Guide

### Easy Installation (Recommended)

1. **Create Installation Directory**
   - Open File Explorer
   - Navigate to your C: drive
   - Create a new folder called `cryptex`

2. **Download and Extract Files**
   - Click this link to download: [Download Cryptex](https://github.com/hlsitechio/cryptex-cli1/archive/refs/heads/main.zip)
   - When the download completes:
     - Open your Downloads folder
     - Right-click the downloaded ZIP file (cryptex-cli1-main.zip)
     - Select "Extract All..."
     - In the Extract window, browse to `C:\cryptex`
     - Click "Extract"
   - You should now have the files in `C:\cryptex\cryptex-cli1-main`

3. **Install Cryptex**
   - Press Windows key + X and click "Windows PowerShell" or "Terminal"
   - Copy and paste these commands:
     ```powershell
     cd C:\cryptex\cryptex-cli1-main
     .\install.ps1
     ```
   - When asked where to install:
     - Choose option 1 for "User Documents" (recommended)
     - If it asks to remove existing installation, type 'y'
   - When asked about the API key:
     - Choose 'y' if you have one
     - Choose 'n' if you don't have one yet

4. **After Installation**
   - Close PowerShell completely
   - Open a new PowerShell window
   - Test the installation:
     ```powershell
     cryptex interact "Hello!"
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

## Troubleshooting

### "Cannot run script" Error
If you see this error, run PowerShell as Administrator and enter:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Module Not Found
If `cryptex` command isn't recognized:
1. Make sure you're using a new PowerShell window
2. Try importing the module manually:
   ```powershell
   Import-Module Cryptex
   ```
3. If that doesn't work:
   - Close all PowerShell windows
   - Open a new PowerShell window
   - Run the installer again: `C:\cryptex\cryptex-cli1-main\install.ps1`

### Wrong Installation Location
If you installed to the wrong location:
1. Run the installer again: `C:\cryptex\cryptex-cli1-main\install.ps1`
2. Choose a different installation location

### API Key Issues
If your API key isn't working:
1. Make sure you can use it at [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Try setting it again: `cryptex setkey -Prompt`

## Need Help?

- Check our [Issues page](https://github.com/hlsitechio/cryptex-cli1/issues)
- Create a new issue if you're still stuck
- Contact support at [support@hlsitech.io](mailto:support@hlsitech.io)