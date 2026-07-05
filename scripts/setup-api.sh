#!/bin/bash
# T3MP3ST API Key Setup Script

set -euo pipefail
umask 077

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║           T3MP3ST API KEY CONFIGURATION                   ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

ENV_FILE="$(dirname "$0")/../.env"

if [ -f "$ENV_FILE" ]; then
    echo "[*] Existing .env file found; it will be replaced after you enter a new key."
fi

echo ""
echo "Choose your LLM provider:"
echo "  1) OpenRouter (recommended - access to all models)"
echo "  2) Anthropic (Claude direct)"
echo "  3) OpenAI (GPT models)"
echo ""

read -r -p "Enter choice [1-3]: " choice

case $choice in
    1)
        echo ""
        echo "Get your OpenRouter API key at: https://openrouter.ai/keys"
        read -rsp "Enter your OpenRouter API key: " api_key
        echo ""
        {
            printf 'OPENROUTER_API_KEY=%s\n' "$api_key"
            printf 'LLM_PROVIDER=openrouter\n'
        } > "$ENV_FILE"
        ;;
    2)
        echo ""
        echo "Get your Anthropic API key at: https://console.anthropic.com/"
        read -rsp "Enter your Anthropic API key: " api_key
        echo ""
        {
            printf 'ANTHROPIC_API_KEY=%s\n' "$api_key"
            printf 'LLM_PROVIDER=anthropic\n'
        } > "$ENV_FILE"
        ;;
    3)
        echo ""
        echo "Get your OpenAI API key at: https://platform.openai.com/api-keys"
        read -rsp "Enter your OpenAI API key: " api_key
        echo ""
        {
            printf 'OPENAI_API_KEY=%s\n' "$api_key"
            printf 'LLM_PROVIDER=openai\n'
        } > "$ENV_FILE"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

chmod 600 "$ENV_FILE"

# Add .env to gitignore if not already there
GITIGNORE="$(dirname "$0")/../.gitignore"
if [ -f "$GITIGNORE" ]; then
    if ! grep -q "^\.env$" "$GITIGNORE"; then
        echo ".env" >> "$GITIGNORE"
        echo "[+] Added .env to .gitignore"
    fi
else
    echo ".env" > "$GITIGNORE"
    echo "[+] Created .gitignore with .env"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              CONFIGURATION COMPLETE!                       ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Your API key has been saved to .env (mode 600)"
echo ""
echo "Start the server with:"
echo "  npm run server"
echo ""
