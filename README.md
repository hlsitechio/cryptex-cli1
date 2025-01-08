# Cryptex CLI

A powerful CLI tool for interacting with the Cryptex AI platform.

## Prerequisites

- Windows PowerShell 5.0 or later
- Internet connection

## Installation

To install Cryptex CLI, open PowerShell and run:

```powershell
iwr https://raw.githubusercontent.com/hlsitechio/cryptexcli1/main/install.ps1 -UseBasicParsing | iex
```

If you encounter an error about scripts being disabled, use:

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/hlsitechio/cryptexcli1/main/install.ps1 -UseBasicParsing | iex"
```

## Configuration

After installation, you'll need to set your API key:

```powershell
cryptex setkey YOUR-API-KEY
```

Your API key will be securely stored in your user profile.

## Usage

Start an interactive session:

```powershell
cryptex interact
```

You can also provide an initial prompt:

```powershell
cryptex interact "Hello, Cryptex!"
```

To exit an interactive session, type `exit`.

## Commands

- `cryptex interact [initial-prompt]`: Start an interactive session
- `cryptex setkey <api-key>`: Set your API key
- `cryptex help`: Show help information

## License

MIT License. See [LICENSE](LICENSE) for details.