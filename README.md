# Cryptex CLI

A powerful command-line interface for interacting with Google's Gemini 2.0 Flash AI model. Cryptex CLI provides a seamless way to integrate advanced AI capabilities into your PowerShell environment.

## Features

- 🚀 Direct integration with Google's Gemini 2.0 Flash Experimental model
- 💨 Fast and efficient responses
- 🔒 Secure API key management
- 🔌 Easy installation via PowerShell
- 💻 Interactive command-line interface
- ⚡ Zero dependencies - no Node.js or npm required

## Prerequisites

- Windows PowerShell 5.1 or later
- A Google AI API key ([Get one here](https://makersuite.google.com/app/apikey))

## Installation

### Option 1: Direct Installation (Recommended)

Run the following command in PowerShell:

```powershell
iwr -useb https://raw.githubusercontent.com/hlsitechio/cryptex-cli1/main/install.ps1 | iex
```

### Option 2: Manual Installation

1. Clone the repository:
```powershell
git clone https://github.com/hlsitechio/cryptex-cli1.git
cd cryptex-cli1
```

2. Run the installation script:
```powershell
.\install.ps1
```

## Getting Started

1. Set your Google AI API key:
```powershell
cryptex setkey YOUR-API-KEY
```

2. Start an interactive session:
```powershell
cryptex interact
```

3. Or send a direct prompt:
```powershell
cryptex interact "What is artificial intelligence?"
```

## Usage

### Basic Commands

- `cryptex setkey <api-key>` - Set your Google AI API key
- `cryptex interact` - Start an interactive chat session
- `cryptex interact "<prompt>"` - Send a single prompt
- `cryptex config` - View current configuration
- `cryptex config set` - Update configuration settings

### Interactive Mode

In interactive mode:
- Type your message and press Enter to send
- Type 'exit' to end the session

### Configuration Options

You can customize various settings using the config command:

```powershell
cryptex config set ApiEndpoint "https://your-endpoint"
cryptex config set ApiVersion "v1beta"
cryptex config set DefaultModel "gemini-2.0-flash-exp"
```

## Technical Details

- Uses Google's Gemini 2.0 Flash Experimental model
- Implements secure API key storage
- PowerShell module-based architecture
- Efficient request handling and response streaming

## Troubleshooting

### Common Issues

1. API Key Issues:
   - Ensure your API key is valid
   - Check if the key has been properly set using `cryptex config`

2. Connection Problems:
   - Verify your internet connection
   - Check if the API endpoint is accessible
   - Ensure you're using the correct API version

3. Installation Issues:
   - Run PowerShell as administrator if needed
   - Check if the installation path exists and is writable
   - Verify PowerShell execution policy

### Error Messages

- "API Key not set" - Run `cryptex setkey YOUR-API-KEY`
- "Invalid API key" - Verify your API key is correct
- "No response generated" - Try rephrasing your prompt

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Security

- API keys are stored securely in your user profile
- All communications use HTTPS
- No data is stored or logged during conversations

## Support

For support, please:
1. Check the troubleshooting section
2. Search existing issues
3. Create a new issue if needed

## Acknowledgments

- Google AI for providing the Gemini API
- Contributors and maintainers
- The PowerShell community

---

Made with ❤️ by HLSitechIO