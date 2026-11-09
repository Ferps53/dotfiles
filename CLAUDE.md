# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Visão geral

Dotfiles de NixOS com Hyprland para dois hosts, `ferps-home` e `ferps-work`. O repositório fica em `~/dotfiles`. O `README.md` está desatualizado (cita `zypper`): o sistema real é definido pelo `flake.nix`.

## Comandos

Não há suíte de testes. A validação é compilar os dois hosts, porque quase todos os módulos são compartilhados:

```sh
# Valida um host sem ativar nada (repetir para ferps-work)
nix build --no-link .#nixosConfigurations.ferps-home.config.system.build.toplevel

# Aplica no host atual (requer sudo; é o usuário quem deve rodar)
sudo nixos-rebuild switch --flake ~/dotfiles#$(hostname)

# Ativa os hooks do git e aplica o sistema
./setup.sh

# Formatadores
alejandra <arquivo.nix>
stylua <arquivo.lua>

# Recarrega a Waybar (o processo se chama .waybar-wrapped)
~/.config/waybar/launch.sh
```

O flake só enxerga arquivos rastreados pelo git. Um arquivo novo referenciado pelo Nix precisa de `git add` antes de compilar.

### Hooks (`.githooks/`, ativados pelo `setup.sh`)

- `pre-commit`: formata os `.nix` em stage com Alejandra e os adiciona de volta.
- `post-merge`: roda `sudo nixos-rebuild switch` depois de cada merge ou pull.

## Arquitetura

As configurações vêm de dois mecanismos diferentes, e é preciso saber qual gerencia cada arquivo.

### Nix: pacotes, serviços e temas

- `flake.nix` define um `nixosConfiguration` por host e integra o Home Manager como módulo do NixOS (`useGlobalPkgs`, `useUserPackages`, `backupFileExtension = "backup"`).
- Sistema: `hosts/<host>/configuration.nix` importa `modules/common.nix` e mais `modules/personal.nix` (home) ou `modules/work.nix` (work).
- Usuário: `home/ferps-home.nix` ou `home/work-home.nix` importam `home/modules/common.nix`. Os temas GTK, Qt e de ícones (Catppuccin Macchiato, Papirus) ficam nesse `common.nix`.
- `pkgs/` tem pacotes próprios, e `nixpkgs.overlays` fica em `modules/common.nix`.

### Stow: arquivos em `.config/`

`.config/` e `.icons/` chegam à home por symlinks do GNU Stow. Editar esses arquivos surte efeito sem rebuild, e o Hyprland recarrega `hyprland.lua` ao salvar.

- `~/.config/hypr` é uma pasta real com um symlink por arquivo, então um arquivo novo ali precisa de um novo link.
- Não há `.stow-local-ignore`, então `stow .` também tentaria linkar `home/`, `hosts/`, `flake.nix` etc. Use `stow -n` para simular antes.

### Neovim: fora dos dois

`home/modules/neovim/default.nix` instala os LSPs e as ferramentas, e aponta `~/.config/nvim` para essa mesma pasta com `mkOutOfStoreSymlink`. Os arquivos Lua podem ser editados sem rebuild. Trocar pacotes exige rebuild.

## Particularidades

- **Hyprland usa config em Lua:** o arquivo é `.config/hypr/hyprland.lua` (API `hl.*`), e o exemplo completo está em `share/hypr/hyprland.lua` do pacote. O `hyprctl dispatch` espera Lua: `hyprctl dispatch 'hl.dsp.exec_cmd("app")'`.
- **Autostart:** coloque programas dentro de `hl.on("hyprland.start", ...)`. No topo do arquivo, o comando roda durante o parse, antes de o socket Wayland existir, e a cada reload.
- **Variáveis de ambiente:** as de `home.sessionVariables` não chegam à sessão do Hyprland. O que os apps gráficos precisam vai em `hl.env(...)`, como as variáveis `QT_*`. O `QT_PLUGIN_PATH` inclui a versão do Qt 5 (`qt-5.15.19`) e precisa de ajuste quando ela mudar.
- **Monitores por host:** o `hyprland.lua` é o mesmo nos dois hosts e escolhe os monitores pelo hostname.
- **Taxa de atualização:** `.config/hypr/auto_hz.sh` foi feito para mudar o `eDP-1` entre 60 Hz e 165 Hz conforme a energia, sobrepondo o `hl.monitor`. O `hyprland.lua` o executa em `~/.config/hypr/auto_hz.sh`, então ele só roda se esse symlink existir.
- **Tema dos apps KDE:** o `kdeglobals` gerado precisa de `[UiSettings] ColorScheme`. Sem isso, o `KColorSchemeManager` aplica uma paleta Breeze por cima do Kvantum e o Dolphin fica com texto ilegível.
- **Ícones da Waybar:** a fonte é JetBrainsMono Nerd Font v3, que não tem os códigos antigos do Material Design (como `U+F590`). Confira com `fc-list ":charset=f590" family`.
- **Editando caracteres de ícones:** os da faixa `U+E000`–`U+F8FF` podem não aparecer na saída das ferramentas. Inspecione com `od -c` e use o escape `\uXXXX` no `old_string` e no `new_string` do Edit.
