#!/bin/bash

# Termux Auto-Install Script
# A stylish, modern Termux setup with Zsh, Starship, Zoxide, and more.

set -e

echo "Updating packages..."
pkg update && pkg upgrade -y

echo "Installing dependencies..."
pkg install zsh starship zoxide fzf eza bat fastfetch git curl -y

# Install Oh My Zsh (non-interactive)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Zsh Plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
echo "Installing Zsh plugins..."
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# Create necessary directories
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.termux"

echo "Applying configurations..."

# Create .zshrc
cat << 'EOF' > "$HOME/.zshrc"
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Aliases for modern tools
alias ls="eza --icons --group-directories-first"
alias ll="eza -lh --icons --group-directories-first"
alias la="eza -a --icons --group-directories-first"
alias lla="eza -lah --icons --group-directories-first"
alias cat="bat"
alias tree="eza --tree --icons"

# Fastfetch on startup
if command -v fastfetch &> /dev/null; then
    fastfetch --logo arch_small -s os:host:kernel:uptime:packages:shell:cpu:memory:disk
fi

# Initialize modern tools
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)
EOF

# Create starship.toml
cat << 'EOF' > "$HOME/.config/starship.toml"
add_newline = true

format = '''
[┌─](bold blue) [Capsd](bold blue) $directory$git_branch
[└─](bold blue)$character'''

[hostname]
ssh_only = false
format = "on [$hostname](bold yellow) "
disabled = true

[directory]
style = "bold cyan"
truncation_length = 3
truncation_symbol = "…/"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"

[git_branch]
symbol = "󰊢 "
style = "bold purple"
EOF

# Create colors.properties
cat << 'EOF' > "$HOME/.termux/colors.properties"
background=#1a1b26
foreground=#c0caf5
cursor=#ff007c
color0=#15161e
color1=#f7768e
color2=#9ece6a
color3=#e0af68
color4=#7aa2f7
color5=#bb9af7
color6=#7dcfff
color7=#a9b1d6
color8=#414868
color9=#f7768e
color10=#9ece6a
color11=#e0af68
color12=#7aa2f7
color13=#bb9af7
color14=#7dcfff
color15=#c0caf5
EOF

# Create termux.properties (basic version)
cat << 'EOF' > "$HOME/.termux/termux.properties"
# Enable extra keys
extra-keys = [['ESC','/','-','HOME','UP','END','PGUP'], \
              ['TAB','CTRL','ALT','LEFT','DOWN','RIGHT','PGDN']]
EOF

echo "Reloading Termux settings..."
termux-reload-settings

# Set Zsh as default shell
if [ "$SHELL" != "/data/data/com.termux/files/usr/bin/zsh" ]; then
    echo "Setting Zsh as default shell..."
    chsh -s zsh
fi

echo "-------------------------------------------------------"
echo "Setup complete! Please restart Termux for all changes to take effect."
echo "Note: If you want to use the custom font, place your font.ttf in ~/.termux/ and run termux-reload-settings."
echo "-------------------------------------------------------"
