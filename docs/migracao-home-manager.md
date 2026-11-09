# Migração para o Home Manager

**Estado:** planejada, nada migrado  
**Objetivo:** substituir o GNU Stow e declarar os programas do usuário no Home Manager, incluindo o Firefox com extensões e temas.

## Princípios

1. **Um programa por vez.** Cada um é migrado, validado e commitado antes do próximo.
2. **Módulo nativo primeiro.** Use `programs.*` ou `services.*` quando existirem. Uma configuração declarada em Nix é melhor que um arquivo copiado.
3. **Sem atalhos.** Nada de linkar pastas em massa nem de usar `force = true` para evitar colisões. Links antigos são removidos no passo de cada programa.
4. **Mudanças passam por rebuild.** As únicas exceções com `mkOutOfStoreSymlink` são o Neovim, que já funciona assim, e o `hyprland.lua`. Uma exceção nova precisa de um motivo escrito.
5. **Os dois hosts continuam compilando.** Tudo que é comum vai para `home/modules/`; o que é específico vai para `home/ferps-home.nix` ou `home/work-home.nix`.

## Situação atual

| Mecanismo | O que gerencia |
|---|---|
| NixOS (`modules/common.nix`) | quase todos os pacotes, incluindo os programas de usuário |
| Home Manager (`home/modules/`) | temas GTK e Qt, Neovim, virtualização, zathura |
| Stow | `.config/{dunst,hypr,kitty,rofi,rofi-wifi-menu,swaylock,tmux,waybar}`, `.icons`, `bluetooth.sh` |
| Fora do repositório | `~/.config/fish`, `~/.config/kitty/current-theme.conf` e os perfis do Firefox |

## Como migrar um programa

Esta é a receita usada em todas as fases.

**1. Preparar**

- [ ] Ler as opções do módulo no Home Manager fixado no `flake.lock`
- [ ] Salvar o que não estiver no repositório

**2. Declarar**

- [ ] Criar `home/modules/<programa>.nix` (ou uma pasta, se houver arquivos auxiliares) e importar em `home/modules/common.nix`
- [ ] Traduzir a configuração atual sem mudar comportamento; melhorias ficam para outro commit
- [ ] Remover o pacote de `environment.systemPackages`, porque o módulo já o instala
- [ ] Rodar `git add` nos arquivos novos, porque o flake só enxerga o que o git rastreia

**3. Validar sem ativar**

- [ ] Compilar os dois hosts:

```sh
nix build --no-link .#nixosConfigurations.ferps-home.config.system.build.toplevel
nix build --no-link .#nixosConfigurations.ferps-work.config.system.build.toplevel
```

**4. Ativar**

- [ ] Remover o link antigo do Stow, conferindo antes que ele aponta para `~/dotfiles`. O Home Manager recusa substituir links que não criou (`would be clobbered`)
- [ ] Rodar `sudo nixos-rebuild switch --flake ~/dotfiles#$(hostname)`
- [ ] Se a ativação falhar, consultar `journalctl -u home-manager-ferps`

**5. Conferir e fechar**

- [ ] Testar o programa de verdade, incluindo reinício e atalhos
- [ ] Apagar de `.config/` os arquivos que deixaram de ser usados
- [ ] Fazer o commit
- [ ] Marcar a fase neste documento

**Para reverter:** `sudo nixos-rebuild switch --rollback` volta ao sistema anterior. Se o link do Stow tiver sido removido, recrie-o ou reverta o commit.

No `ferps-work`, repita a etapa 4 quando estiver naquele computador. Ele só é validado por compilação daqui.

## Decisões

**Tomadas em 08/11/2026:**

| Decisão | Escolha | Consequência |
|---|---|---|
| Configs dos programas | Mudanças passam por rebuild | Os arquivos gerados ficam no Nix store, somente leitura. Inclui a Waybar. |
| `hyprland.lua` | Continua editável, sem rebuild | Exceção com `mkOutOfStoreSymlink`, como o Neovim. O Hyprland segue recarregando ao salvar. |
| Perfis do Firefox | Unificar em um só | A base é o `09pf1y1k.default`, o perfil em uso. Ver a fase 5. |
| `auto_hz.sh` | Reativar a troca automática, mantendo o brilho | Na tomada: 165 Hz e brilho 100%. Na bateria: 60 Hz e brilho 25%. Ver a fase 6. |

**Ainda em aberto:**

| Decisão | Quando | Observação |
|---|---|---|
| Tema: flake `catppuccin/nix` ou arquivo local com a paleta | Fase 0 | O flake pode evitar repetir cores em cada programa, mas adiciona uma dependência. |
| Origem das extensões do Firefox | Fase 5 | NUR ou política `ExtensionSettings`. |

## Plano

As fases vão do menor risco ao maior. A ordem das fases 1 a 5 pode mudar; a fase 7 é sempre a última.

### Fase 0: preparação

- [ ] Commitar o trabalho pendente (`CLAUDE.md`, `README.md`, temas)
- [ ] Avaliar o `catppuccin/nix` (programas cobertos, compatibilidade com o `nixos-unstable` e com o tema já declarado) e decidir o tema
- [ ] Criar a estrutura de `home/modules/`, com um arquivo por programa

### Fase 1: ferramentas simples

Sem estado e sem impacto na sessão. Servem para validar a receita.

- [ ] `btop` (`programs.btop`)
- [ ] `fastfetch` (`programs.fastfetch`)
- [ ] `zathura` (`programs.zathura`), hoje em `home.packages`
- [ ] `git` (`programs.git`), que já tem o e-mail por host em `home/ferps-home.nix` e `home/work-home.nix`
- [ ] `gh` (`programs.gh`)
- [ ] `direnv` (`programs.direnv`), hoje em `programs.direnv.enable` no sistema

### Fase 2: terminal

- [ ] **`kitty`** (`programs.kitty`): incorporar o `current-theme.conf`, que só existe localmente, antes de remover o link
- [ ] **`tmux`** (`programs.tmux`): trocar o TPM e os plugins em `.config/tmux` (`catppuccin-tmux`, `tmux-sensible`, `tmux-yank`) por `programs.tmux.plugins`
- [ ] **`fish`** (`programs.fish`): levar `~/.config/fish` para o repositório antes, porque hoje não é versionado. Revisar `conf.d`, `fish_plugins` e `fishline`. Manter `programs.fish.enable` no sistema, porque é o shell de login

### Fase 3: serviços da sessão

Os módulos desta fase costumam criar serviços systemd de usuário, em vez de usar `hl.exec_cmd`.

**Antes de migrar qualquer serviço:**

- [ ] Entender o `nixos-fake-graphical-session.target` iniciado no `hyprland.lua` e como os serviços se ligam ao `graphical-session.target`
- [ ] Descobrir por que `home.sessionVariables` não chega à sessão do Hyprland. O objetivo é eliminar os `hl.env("QT_*")`, especialmente o caminho com a versão fixa `qt-5.15.19`

**Depois, um por vez, removendo a chamada correspondente em `hyprland.start`:**

- [ ] `hyprpaper` (`services.hyprpaper`)
- [ ] `hypridle` (`services.hypridle`)
- [ ] `hyprlock` (`programs.hyprlock`)
- [ ] `dunst` (`services.dunst`), incluindo os ícones em `.config/dunst`
- [ ] `hyprpolkitagent` (`services.hyprpolkitagent`)
- [ ] `blueman-applet` (`services.blueman-applet`), lembrando que o plano de `docs/plano-barras-blueman.md` altera o pacote
- [ ] `nm-applet` (`services.network-manager-applet`)
- [ ] `cliphist` (`services.cliphist`), avaliando se já está em uso

### Fase 4: barra e menus

- [ ] **`waybar`** (`programs.waybar`): migrar `config.jsonc` para `settings` e `style.css` para `style`. Decidir o destino de `launch.sh`, `mediaplayer.py` e `power_menu.xml`. Com o serviço systemd, o atalho `SUPER+SHIFT+B` passa a reiniciar o serviço
- [ ] **`rofi`** (`programs.rofi`): migrar `config.rasi`
- [ ] **`rofi-wifi-menu`**: empacotar o script com `writeShellApplication`, em vez de chamá-lo por caminho em `hyprland.lua` e na Waybar

### Fase 5: Firefox

É a fase de maior risco de dados, porque os perfis têm logins e o histórico. Faça em etapas e com backup.

**O que existe hoje** (Firefox 159.0.1):

| Perfil | Tamanho | Último uso | Extensões ativas |
|---|---|---|---|
| `09pf1y1k.default` (**base**) | 2,2 GB | em uso (08/11/2026) | Bitwarden, AdNauseam, Image Max URL, Turn Off the Lights, Marreta, Remove Paywall |
| `7is5b7rd.default-release` | 970 MB | 27/04/2026 | Bitwarden, AdNauseam, Improve YouTube, Fetch Video Downloader |

Os dois usam o tema Catppuccin Macchiato Blue e têm um login salvo cada. O Firefox Sync não está configurado em nenhum, então ele não ajuda a unificar.

**Preparação:**

- [ ] Fechar o Firefox e fazer backup de `~/.mozilla/firefox`
- [ ] Confirmar a pasta que o Home Manager usa nesta `stateVersion`
- [ ] Verificar a origem de cada extensão:
  - [ ] As opções são o NUR (`nur.repos.rycee.firefox-addons`, usado no exemplo do módulo) e a política `ExtensionSettings`, com o link oficial da extensão
  - [ ] O `Remove Paywall` tem o ID `remove-paywall@example.com`, o que sugere instalação manual. Confirmar de onde ele vem
  - [ ] O tema Catppuccin também precisa de uma origem confirmada

**Unificar os perfis, antes de declarar qualquer coisa:**

- [ ] Listar o que só existe no perfil antigo: favoritos, o login salvo, buscadores e ajustes das extensões
- [ ] Exportar os favoritos do perfil antigo e importá-los no perfil base, revisando duplicatas
- [ ] Levar o login salvo para o Bitwarden, se ainda não estiver lá
- [ ] Levar a configuração do Improve YouTube, se ele tiver opção de exportar
- [ ] Não copiar o histórico nem os cookies do perfil antigo: os dados têm mais de seis meses, e copiar arquivos entre perfis é arriscado

**Migrar para o Home Manager, em etapas:**

- [ ] Declarar `programs.firefox.profiles.default.path = "09pf1y1k.default"`, para reaproveitar o perfil em vez de criar um vazio
- [ ] Ativar só isso e confirmar que logins, histórico e abas continuam lá
- [ ] Conferir que o `profiles.ini` gerado aponta para o perfil base, incluindo a seção `[Install]`, que hoje indica o perfil antigo
- [ ] Declarar as extensões unificadas em etapas, começando pelas de menor risco:
  - [ ] Bitwarden
  - [ ] AdNauseam
  - [ ] Image Max URL
  - [ ] Turn Off the Lights
  - [ ] Marreta
  - [ ] Remove Paywall
  - [ ] Improve YouTube
  - [ ] Fetch Video Downloader
- [ ] Declarar o tema
- [ ] Declarar `settings` (`about:config`), só para o que quiser fixar
- [ ] Remover `firefox` de `environment.systemPackages`

**Fechamento:**

- [ ] Usar o perfil unificado por um tempo e confirmar que nada faltou
- [ ] Só então apagar `7is5b7rd.default-release` e o backup

**Ficam de fora:** logins e dados do Bitwarden. As configurações internas de cada extensão só entram quando a extensão suportar configuração gerenciada; confira uma a uma.

### Fase 6: Hyprland

O módulo `wayland.windowManager.hyprland` da versão fixada não menciona configuração em Lua, e a sua config é em Lua. Por isso:

- [ ] Confirmar se o módulo já suporta Lua. Se suportar, reavaliar esta fase
- [ ] Manter `programs.hyprland.enable` no sistema
- [ ] Declarar `.config/hypr/hyprland.lua` com `xdg.configFile` e `mkOutOfStoreSymlink`, para continuar editável. Comentar o motivo no Nix: é o arquivo mais ajustado, e o Hyprland recarrega ao salvar
- [ ] Linkar só o `hyprland.lua`, não a pasta `hypr`, porque os outros arquivos vêm dos módulos da fase 3
- [ ] Mover o `toggle_rf.sh` para `writeShellApplication` ou o wrapper adequado à linguagem dele
- [ ] Reativar o `auto_hz.sh`:
  - [ ] Empacotar com `pkgs.writers.writeFishBin`, porque o script é em fish, declarando as dependências no `PATH` (`hyprctl`, `jq`, `brightnessctl`, `notify-send` e `udevadm`)
  - [ ] Atualizar a chamada em `hyprland.start`, ou trocá-la por um serviço systemd de usuário se a investigação da fase 3 apontar esse caminho
  - [ ] Decidir o valor do `eDP-1` em `hl.monitor`, hoje fixo em 60 Hz, sabendo que o script sobrepõe esse valor
  - [ ] Manter a troca de brilho do script (100% na tomada e 25% na bateria)
  - [ ] Testar ligando e tirando da tomada: taxa de atualização, brilho e notificação
- [ ] Declarar o cursor em `home.pointerCursor` e `gtk.cursorTheme`, removendo as chamadas `hyprctl setcursor` e `gsettings set` do `hyprland.start` e a pasta `.icons`

### Fase 7: fim do Stow

- [ ] Confirmar que nada mais depende de links do Stow com `find ~ ~/.config -maxdepth 1 -type l -lname '*dotfiles*'`
- [ ] Revisar `swaylock`: sem pacote instalado e com `hyprlock` em uso, é candidato a remoção
- [ ] Revisar `bluetooth.sh`: nada no repositório o referencia
- [ ] Remover os links quebrados de `~/.config` (`waybar.tar.gz`, `wlogout`, `hypridle.conf`, `hyprland.conf`, `hyprlock.conf`, `hyprpaper.conf`, `images`, `nvim-test`, `toggle_rf.sh`, `wallpaper.jpg`) e `~/.zshrc`
- [ ] Remover `stow` de `modules/common.nix`
- [ ] Mover os pacotes restantes de usuário para `home.packages`:
  - [ ] Apps: `spotify`, `discord`, `libreoffice`, `vlc`, `obs-studio`, `blender` e `google-chrome`
  - [ ] Ficam no sistema: `docker`, drivers, bibliotecas para `nix-ld` e o que a sessão exige
  - [ ] Eliminar duplicatas entre `modules/common.nix` e `home/modules/neovim/default.nix` (como `alejandra`, `ripgrep` e LSPs)
- [ ] Atualizar `README.md` e `CLAUDE.md`
- [ ] Repetir a limpeza no `ferps-work`

## Riscos

- **Dados locais:** `current-theme.conf`, `~/.config/fish` e os perfis do Firefox não estão no git. Faça a cópia antes de qualquer remoção.- **Serviços que não sobem:** se o `graphical-session.target` não ativar como esperado, os serviços da fase 3 não iniciam. Por isso a investigação vem antes.
- **Sem barra ou papel de parede:** migrar a sessão em ambiente gráfico pode exigir reiniciar a sessão para ver o resultado. Tenha um terminal aberto e o rollback à mão.
- **Dois hosts:** o `ferps-work` só é testado de verdade quando estiver naquele computador.

## O que não foi verificado

- Os módulos foram confirmados pelos arquivos do Home Manager fixado. As opções de cada um só são lidas na fase de cada programa.
- A ausência de Lua no módulo de Hyprland vem de uma busca por texto no arquivo do módulo.
- A disponibilidade de cada extensão no NUR não foi consultada.
