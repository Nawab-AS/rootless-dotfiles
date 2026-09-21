#!/bin/bash

cd ~

# download fish binary
wget https://github.com/fish-shell/fish-shell/releases/download/4.9.3/fish-4.9.3-linux-x86_64.tar.xz

# extract
tar -xJf ~/fish-4.9.3-linux-x86_64.tar.xz
rm ~/fish-4.9.3-linux-x86_64.tar.xz

# move to local bin
mkdir -p ~/.local/bin
mv ~/fish ~/.local/bin/fish

# write pseudo-default shell
cat << 'EOF' > ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
export TERM=xterm-256color

if [[ $- == *i* ]]; then
    if [ "$SHLVL" -eq 1 ] && [ -x "$(command -v fish)" ]; then
        export SHELL=$(command -v fish)
        exec fish
    fi
fi
EOF

cat << 'EOF' > ~/.profile
# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
EOF


# install nvim
mkdir -p ~/.config/nvim
curl -LO https://github.com/neovim/neovim/releases/download/v0.12.5/nvim-linux-x86_64.appimage
chmod u+x ~/nvim-linux-x86_64.appimage
~/nvim-linux-x86_64.appimage --appimage-extract
mv ~/squashfs-root ~/.local/nvim-root
rm ~/nvim-linux-x86_64.appimage
ln -s ~/.local/nvim-root/usr/bin/nvim ~/.local/bin/nvim

# install lazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

