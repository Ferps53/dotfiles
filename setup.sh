#!/usr/bin/env bash

echo "Configurando ambiente das dotfiles..."

git config core.hooksPath .githooks
echo "Git hooks ativados"

CURRENT_HOST=$(hostname)
echo "Aplicando NixOS para o host: $CURRENT_HOST"
sudo nixos-rebuild switch --flake .#$CURRENT_HOST
