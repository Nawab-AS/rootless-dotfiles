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

mv ~/fish ~/.local/fish
ln -sf ~/.local/fish/bin/fish ~/.local/bin/fish

# Configure shell files
echo "Configuring shell files..."
cat << 'EOF' > ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
export TERM=xterm-256color

if [[ $- == *i* ]]; then
    if [ "$SHLVL" -eq 1 ] && command -v fish >/dev/null 2>&1; then
        export SHELL=$(command -v fish)
        exec fish
    fi
fi
EOF

cat << 'EOF' > ~/.profile
# If running bash, include .bashrc if it exists
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# Add user's private bin to PATH if it exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
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
