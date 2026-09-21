#!/bin/bash
set -euo pipefail  # Fail on errors, unset variables, and pipeline errors

# Define variables for reuse
FISH_VERSION="4.9.3"
FISH_URL="https://github.com/fish-shell/fish-shell/releases/download/${FISH_VERSION}/fish-${FISH_VERSION}-linux-x86_64.tar.xz"
FISH_TAR="fish-${FISH_VERSION}-linux-x86_64.tar.xz"

NEOVIM_VERSION="v0.12.5"
NEOVIM_URL="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-x86_64.appimage"
NEOVIM_APPIMAGE="nvim-linux-x86_64.appimage"
NEOVIM_ROOT_DIR="nvim-root"

# Create directories if they don't exist
mkdir -p ~/.local/bin
mkdir -p ~/.config/nvim

# Install Fish Shell
echo "Downloading Fish Shell..."
wget -q "$FISH_URL" -O "$FISH_TAR" || { echo "Failed to download Fish Shell"; exit 1; }

echo "Extracting Fish Shell..."
tar -xJf "$FISH_TAR" || { echo "Failed to extract Fish Shell"; exit 1; }
rm "$FISH_TAR"

# Find the Fish binary (handles both directory and direct binary cases)
FISH_BIN=$(find . -name "fish" -type f -executable | head -n 1)
if [ -z "$FISH_BIN" ]; then
    echo "Fish binary not found in extracted directory."
    exit 1
fi

# Move Fish binary directly to ~/.local/bin (NO SYMLINK)
mv "$FISH_BIN" ~/.local/bin/fish

# Configure shell files
echo "Configuring shell files..."
cat << 'EOF' > ~/.profile
# Add user's private bin to PATH
export PATH="$HOME/.local/bin:$PATH"
export TERM=xterm-256color

# Launch Fish Shell if available
if command -v fish >/dev/null 2>&1; then
    export SHELL=$(command -v fish)
    exec fish
fi

# If running bash, include .bashrc if it exists
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
EOF

cat << 'EOF' > ~/.bashrc
# Only launch Fish for interactive non-login shells
if [[ $- == *i* ]] && [ "$SHLVL" -eq 1 ]; then
    if command -v fish >/dev/null 2>&1; then
        exec fish
    fi
fi
EOF

# Install Neovim
echo "Downloading Neovim..."
curl -LO "$NEOVIM_URL" || { echo "Failed to download Neovim"; exit 1; }

echo "Setting up Neovim..."
chmod u+x "$NEOVIM_APPIMAGE"
./"$NEOVIM_APPIMAGE" --appimage-extract || { echo "Failed to extract Neovim"; exit 1; }
mv squashfs-root ~/.local/"$NEOVIM_ROOT_DIR"
rm "$NEOVIM_APPIMAGE"
ln -sf ~/.local/"$NEOVIM_ROOT_DIR"/usr/bin/nvim ~/.local/bin/nvim

# Install LazyVim
echo "Installing LazyVim..."
git clone --depth 1 https://github.com/LazyVim/starter ~/.config/nvim || { echo "Failed to clone LazyVim"; exit 1; }
rm -rf ~/.config/nvim/.git

echo "Installation complete!"
echo "Please logout and log back in to reflect changes. Run: logout"
