# Rootless dotfiles!

### One-line Installer
Run this command:
```bash
curl -fsSL https://nawab-as.dev/rootless-dotfiles/install.sh | bash
```
Then logout and back it.

### But... why rootless?
My uni has a a linux server (yay), but I don't have sudo privileges ofc.
Additionally, it has a very basic environment, basically a fresh bare Debian install.

For a uni, fair enough. but no fish auto-complete and using NANO as a code editor is just diabolical. nvim is the bare minimum.

Anyways, this is just a repo of dotfiles that I can run without sudo.

This repo installs:
 - fish shell as pseudo-default interactive login shell
 - LazyVim (cuz why not)
