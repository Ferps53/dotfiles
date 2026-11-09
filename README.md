# Minhas .dotfiles

Configuração de NixOS com Hyprland para dois computadores, definida por um flake com Home Manager. O tema é Catppuccin Macchiato.

| Host | Uso |
|---|---|
| `ferps-home` | computador pessoal |
| `ferps-work` | computador do trabalho |

## Estrutura

| Caminho | Conteúdo | Como aplicar |
|---|---|---|
| `flake.nix`, `hosts/`, `modules/` | sistema: pacotes e serviços | rebuild |
| `home/`, `pkgs/` | usuário: temas, Neovim e pacotes próprios | rebuild |
| `.config/`, `.icons/` | Hyprland, Waybar, kitty e outros | symlinks do Stow |
| `home/modules/neovim/` | config do Neovim, linkada direto pelo Home Manager | só o rebuild para trocar pacotes |

## Como instalar

Requer NixOS com flakes habilitados, e o repositório precisa estar em `~/dotfiles`.

1. Clone o repositório:

   ```sh
   git clone <url-do-repositorio> ~/dotfiles
   cd ~/dotfiles
   ```

2. Em um computador novo, defina o hostname como `ferps-home` ou `ferps-work` e atualize o `hosts/<host>/hardware-configuration.nix`.

3. Ative os hooks do git e aplique o sistema. O script usa o hostname atual para escolher a configuração:

   ```sh
   ./setup.sh
   ```

4. Simule os symlinks antes de criá-los:

   ```sh
   stow -n -v .
   ```

   **Atenção:** o repositório não tem `.stow-local-ignore`, então `stow .` também cria links na home para `home/`, `hosts/`, `flake.nix` e outros arquivos que não são configuração. Confira a lista da simulação antes de executar sem o `-n`.

## Uso no dia a dia

```sh
# Aplica mudanças do Nix no host atual
sudo nixos-rebuild switch --flake ~/dotfiles#$(hostname)

# Só valida um host, sem ativar nada
nix build --no-link .#nixosConfigurations.ferps-home.config.system.build.toplevel
```

Mudanças em `.config/` valem sem rebuild, e o Hyprland recarrega o `hyprland.lua` ao salvar. O flake só enxerga arquivos rastreados pelo git, então use `git add` em arquivos novos antes de compilar.

## Hooks do git

Ativados pelo `setup.sh`:

- **`pre-commit`:** formata os arquivos `.nix` em stage com Alejandra.
- **`post-merge`:** roda `nixos-rebuild switch` depois de cada merge ou pull e pede a senha do `sudo`.
