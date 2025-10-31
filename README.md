# Dotfiles

Personal development environment configuration files and terminal customization.

## What's Included

- **Starship prompt** - Beautiful, fast shell prompt with git status, language indicators, and Powerlevel10k-inspired colors
- **Windows Terminal setup** - Color schemes and font recommendations for the best terminal experience  
- **Personal configuration templates** - Shell configurations and personal development tools

## Architecture Note

This repository focuses on **personal configuration files only**. For infrastructure setup and development environment provisioning, see:
- **Infrastructure Layer**: [crank-infrastructure](https://github.com/crankbird/crank-infrastructure) - Environment setup, containers, cloud deployment
- **Platform Layer**: [crank-platform](https://github.com/crankbird/crank-platform) - Service mesh and governance

## Quick Install

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Install starship prompt and personal configurations
chmod +x install.sh
./install.sh
```

For complete development environment setup, use [crank-infrastructure](https://github.com/crankbird/crank-infrastructure).

## Manual Setup

### Starship Prompt

1. Install starship (if not already installed):
```bash
curl -sS https://starship.rs/install.sh | sh -s -- -y
```

2. Copy the configuration:
```bash
cp starship/starship.toml ~/.config/starship.toml
```

3. Add to your shell rc file:
```bash
# For bash
echo 'eval "$(starship init bash)"' >> ~/.bashrc

# For zsh  
echo 'eval "$(starship init zsh)"' >> ~/.zshrc
```

### Windows Terminal

See `terminal-setup/README.md` for detailed instructions on:
- Installing MesloLGS Nerd Font
- Applying color schemes (Dracula, One Dark, Nord, Tokyo Night)
- Configuring your WSL profile

## Features

### Starship Prompt
- 🎨 **Beautiful colors** - Inspired by Powerlevel10k with cyan, purple, coral accents
- 📁 **Smart directory display** - Shows repo root + truncated path
- 🔀 **Rich git status** - Ahead/behind, staged, modified, conflicts, etc.
- 🐍 **Language indicators** - Python virtualenv/version, Node.js version
- ⚡ **Fast performance** - Optimized timeouts and minimal modules
- ✅ **Clean symbols** - Green ❯ success, red ✖ error

### Terminal Colors
- Multiple carefully selected color schemes
- Proper contrast and readability
- Consistent with popular themes (Dracula, One Dark, etc.)
- Optimized for development work

## Structure

```
dotfiles/
├── starship/
│   └── starship.toml              # Starship prompt configuration
├── terminal-setup/
│   └── README.md                  # Windows Terminal setup guide
├── templates/                     # Configuration file templates
├── install.sh                     # Main dotfiles installer script
└── README.md                      # This file
```

## Related Repositories

For infrastructure and development environment setup:
- **[crank-infrastructure](https://github.com/crankbird/crank-infrastructure)** - Environment provisioning, containers, cloud setup
- **[crank-platform](https://github.com/crankbird/crank-platform)** - Service mesh, security patterns, governance

## Customization

- Edit `starship/starship.toml` to modify prompt appearance
- Colors are defined with hex values for easy customization
- Modules can be enabled/disabled by setting `disabled = true/false`
- Directory truncation and git display can be adjusted

## Requirements

- WSL/Ubuntu or similar Linux environment
- Starship prompt (installer will prompt if missing)
- MesloLGS Nerd Font (for proper icon display)
- Windows Terminal (for color schemes)

## License

MIT - Feel free to use and modify for your own setup!