# Cryptex CLI

A PowerShell-based CLI tool for interacting with Google's Gemini AI.

## Step-by-Step Installation Guide

### Method 1: Easy Installation (Recommended)

1. **Create Installation Directory**
   - Open File Explorer
   - Navigate to your C: drive
   - Create a new folder called `cryptex`
   - Inside `cryptex`, create another folder called `cryptex-cli1`

2. **Download Files**
   - Click this link to download: [Download Cryptex](https://github.com/hlsitechio/cryptex-cli1/archive/refs/heads/main.zip)
   - When the download completes, find the ZIP file in your Downloads folder
   - Right-click the ZIP file and select "Extract All..."
   - Copy all files from the extracted folder into `C:\cryptex\cryptex-cli1`

3. **Install Cryptex**
   - Open PowerShell (press Windows key, type "powershell", and click "Windows PowerShell")
   - Copy and paste this command:
     ```powershell
     cd C:\cryptex\cryptex-cli1
     ```
   - Then run the installer:
     ```powershell
     .\install.ps1
     ```
   - Choose where to install (recommended: option 1 for "User Documents")
   - When asked about the API key, choose 'y' if you have one, 'n' if you don't yet

### Method 2: Using Git (For Developers)

```powershell
# Clone the repository
git clone https://github.com/hlsitechio/cryptex-cli1.git
cd cryptex-cli1

# Run the installer
.\install.ps1
```

## Getting Your API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy your new API key

## Setting Up Your API Key

1. Open PowerShell
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
1. Close and reopen PowerShell
2. Run the installer again: `C:\cryptex\cryptex-cli1\install.ps1`

### Wrong Installation Location
If you installed to the wrong location:
1. Run the installer again: `C:\cryptex\cryptex-cli1\install.ps1`
2. Choose a different installation location

### API Key Issues
If your API key isn't working:
1. Make sure you can use it at [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Try setting it again: `cryptex setkey -Prompt`

## Need Help?

- Check our [Issues page](https://github.com/hlsitechio/cryptex-cli1/issues)
- Create a new issue if you're still stuck
- Contact support at [support@hlsitech.io](mailto:support@hlsitech.io)