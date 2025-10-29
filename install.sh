#!/usr/bin/env bash
set -euo pipefail

# Dotfiles installer - sets up development environment configurations
# Run from the dotfiles repo root: ./install.sh

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Setting up dotfiles from: $DOTFILES_ROOT"

# Install Starship configuration
install_starship() {
    echo "📦 Installing Starship configuration..."
    
    local src="$DOTFILES_ROOT/starship/starship.toml"
    local dest="$HOME/.config/starship.toml"
    
    if [ ! -f "$src" ]; then
        echo "❌ ERROR: Starship config not found at $src"
        return 1
    fi
    
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "✅ Copied starship config to: $dest"
    
    # Check for starship binary
    if command -v starship >/dev/null 2>&1; then
        echo "✅ starship is already installed"
    else
        echo "⚠️  starship is not installed. Install with:"
        echo "   curl -sS https://starship.rs/install.sh | sh -s -- -y"
    fi
    
    # Add init to shells if missing
    local init_bash='eval "$(starship init bash)"'
    local init_zsh='eval "$(starship init zsh)"'
    
    append_if_missing "$HOME/.bashrc" "$init_bash"
    append_if_missing "$HOME/.zshrc" "$init_zsh"
    
    echo "✅ Starship setup complete"
}

# Helper function to append lines to files if not already present
append_if_missing() {
    local file="$1"
    local line="$2"
    
    if [ -f "$file" ]; then
        if ! grep -Fqx "$line" "$file"; then
            printf "\n# Starship prompt\n%s\n" "$line" >> "$file"
            echo "✅ Added starship init to $file"
        else
            echo "✅ $file already includes starship init"
        fi
    else
        echo "⚠️  $file not found, skipping"
    fi
}

# Main installation
main() {
    echo "🎯 Installing dotfiles configuration..."
    echo
    
    install_starship
    
    echo
    echo "🎉 Dotfiles installation complete!"
    echo
    echo "Next steps:"
    echo "1. Install starship if not already installed:"
    echo "   curl -sS https://starship.rs/install.sh | sh -s -- -y"
    echo
    echo "2. Configure Windows Terminal:"
    echo "   - Set font to 'MesloLGS NF' (install from nerd-fonts if needed)"
    echo "   - Apply a color scheme (Dracula recommended)"
    echo "   - See terminal-setup/README.md for details"
    echo
    echo "3. Restart your terminal to see the new prompt!"
    echo
    echo "🤖 Optional: Set up AI/ML development environment:"
    echo "   ./dev-environment/install-aiml.sh"
    echo "   ./dev-environment/check-env.sh      # Check current status"
}

# Run main function
main "$@"