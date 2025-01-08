@echo off
echo 🌟 Setting up Cryptex for Windows...

:: Check for Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js is required but not installed!
    echo Please install Node.js from https://nodejs.org/
    exit /b 1
)

:: Install dependencies
echo 📦 Installing dependencies...
npm install

:: Create .env if it doesn't exist
if not exist .env (
    echo CRYPTEX_GOOGLE_AI_KEY=your_sacred_key_of_power > .env
    echo 📜 Created .env file
)

:: Install CLI globally
echo 🔮 Installing Cryptex CLI...
npm link cryptex-cli

echo ✨ Setup complete! You can now use 'cryptex' from anywhere.
echo Try 'cryptex interact' to begin your magical journey!