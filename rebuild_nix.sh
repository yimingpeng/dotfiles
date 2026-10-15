#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if [ "$DIR" != "$HOME/.dotfiles" ]; then
  ln -sfn "$DIR" "$HOME/.dotfiles"
fi
ln -sfn "$DIR" ~/.dotfiles
sudo darwin-rebuild switch --flake ~/.dotfiles/nix#Yiming-iMac
# Homebrew holds only casks (prebuilt apps), so this never source-builds.
# No `brew update`: the switch already ran it (homebrew.onActivation.autoUpdate).
brew upgrade
