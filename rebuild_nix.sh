#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if [ "$DIR" != "$HOME/.dotfiles" ]; then
  ln -sfn "$DIR" "$HOME/.dotfiles"
fi
ln -sfn "$DIR" ~/.dotfiles
exec sudo darwin-rebuild switch --flake ~/.dotfiles/nix#Yiming-iMac
