#!/bin/bash

echo "🌟 Setting up Cryptex..."

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not installed!"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    echo "CRYPTEX_GOOGLE_AI_KEY=your_sacred_key_of_power" > .env
    echo "📜 Created .env file"
fi

# Install CLI globally
echo "🔮 Installing Cryptex CLI..."
npm link cryptex-cli

echo "✨ Setup complete! You can now use 'cryptex' from anywhere."
echo "Try 'cryptex interact' to begin your magical journey!"