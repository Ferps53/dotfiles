# Plano: redesenhar as barras do Blueman

**Estado:** pendente  
**Decisão:** opção 2, redesenhar as barras (escolhida por qualidade, em vez de só recolorir ou esconder)

## Objetivo

Trocar as barras de sinal, potência e bateria do Blueman Manager por barras lisas e arredondadas nas cores do Catppuccin Macchiato, no estilo da Waybar.

Hoje elas têm brilho e listras em laranja, azul e cinza, e destoam do resto do sistema.

## Por que o tema não resolve

O Blueman carrega PNGs fixos do próprio pacote, sem passar pelo tema de ícones nem pelo GTK:

```python
# blueman/gui/manager/ManagerDeviceList.py, Blueman 2.4.6, linhas 522-528
w = 14 * self.get_scale_factor()
h = 48 * self.get_scale_factor()
icon_name = f"blueman-{name}-{int(round(perc, -1))}.png"
GdkPixbuf.Pixbuf.new_from_file_at_scale(os.path.join(PIXMAP_PATH, icon_name), w, h, True)
```

A solução é substituir os arquivos no pacote `blueman`, usando um overlay do Nix. O `PIXMAP_PATH` aponta para `$out/share/blueman/pixmaps`.

## Especificação das imagens

| Item | Valor |
|---|---|
| Pasta | `share/blueman/pixmaps/` |
| Arquivos | `blueman-{battery,rssi,tpl}-{10,20,...,100}.png` (30 no total) |
| Tamanho atual | `rssi` e `tpl`: 56x192 (RGBA); `battery`: 14x48 (cinza + alfa) |
| Tamanho na tela | 14x48 por fator de escala, mantendo a proporção |
| Tamanho sugerido | 56x192 RGBA nos três tipos, proporção de 14x48 |
| Fundo | transparente, porque o fundo muda quando a linha é selecionada |

| Barra | Significado | Cor sugerida |
|---|---|---|
| `rssi` | força do sinal | `peach` `#f5a97f` |
| `tpl` | potência de transmissão | `blue` `#8aadf4` |
| `battery` | bateria, quando o dispositivo informa | `green` `#a6da95` |
| Trilho (opcional) | parte vazia da barra | `surface0` `#363a4f` |

**Comportamento do código a considerar:**

- `rssi` e `tpl` têm mínimo de 10% e usam 50% quando o valor não está disponível, então 50% não significa necessariamente sinal médio.
- A bateria vem direto de `Percentage`. Abaixo de 5%, o arredondamento pede `blueman-battery-0.png`, que não existe no pacote. Isso vem da leitura do código e não foi testado. Gerar esse arquivo extra deve evitar o erro.

## Onde mexer

- **`modules/common.nix`, linha 90:** adicionar o overlay à lista `nixpkgs.overlays`. O `blueman` já está em `environment.systemPackages` (linha 125), e o Home Manager usa `useGlobalPkgs`.
- **`pkgs/blueman-bars/` (novo):** script que gera os PNGs, seguindo a organização de `pkgs/kotlin-lsp.nix`.

Esboço do overlay, a validar:

```nix
(final: prev: {
  blueman = prev.blueman.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [final.imagemagick];
    postInstall = (old.postInstall or "") + ''
      bash ${../pkgs/blueman-bars/generate.sh} "$out/share/blueman/pixmaps"
    '';
  });
})
```

## Checklist

### 1. Protótipo, sem tocar no Nix

- [ ] Decidir o desenho: só a barra, ou barra com símbolo embaixo como hoje
- [ ] Decidir se o trilho da parte vazia entra
- [ ] Escrever `pkgs/blueman-bars/generate.sh`, que recebe a pasta de saída e gera os PNGs com ImageMagick
- [ ] Gerar em uma pasta temporária e montar uma prévia dos níveis 10, 50 e 100 dos três tipos
- [ ] Conferir a prévia em 14x48, o tamanho real, e não só ampliada
- [ ] Conferir a prévia sobre `#24273a` (fundo) e sobre a cor de linha selecionada
- [ ] Aprovar o visual antes de seguir

### 2. Integração

- [ ] Gerar também `blueman-battery-0.png`
- [ ] Adicionar o overlay em `modules/common.nix`
- [ ] Confirmar que `postInstall` é a fase certa (o pacote é Python e tem `makeWrapperArgs`); se não for, usar `postFixup`
- [ ] Rodar `git add` no script novo, porque o flake só enxerga arquivos rastreados pelo git
- [ ] Compilar os dois hosts sem ativar:
  - [ ] `nix build --no-link .#nixosConfigurations.ferps-home.config.system.build.toplevel`
  - [ ] `nix build --no-link .#nixosConfigurations.ferps-work.config.system.build.toplevel`
- [ ] Listar a pasta `pixmaps` do pacote gerado e confirmar os 30 arquivos + o nível 0

### 3. Aplicação e verificação

- [ ] Rodar `sudo nixos-rebuild switch --flake ~/dotfiles#ferps-home`
- [ ] Fechar e reabrir o `blueman-manager` e o `blueman-applet`
- [ ] Com um dispositivo conectado, confirmar as barras novas em linha normal e selecionada
- [ ] Testar um dispositivo que informa bateria, como o `QCY H3S`
- [ ] Testar a variação: afastar o dispositivo ou esperar o sinal mudar
- [ ] Procurar erros ao carregar imagens com `blueman-manager` pelo terminal
- [ ] Conferir se os ícones Papirus e o tema continuam iguais no resto da janela

### 4. Fechamento

- [ ] Fazer o commit do script, do overlay e deste plano atualizado
- [ ] Mudar o estado deste arquivo para concluído, ou apagá-lo

## Riscos

- **Compilação local:** o Blueman deixa de vir pronto do cache e passa a ser compilado na máquina, inclusive quando o `nixpkgs` atualizar. Deve ser rápido, mas não foi medido.
- **Atualizações do Blueman:** se os nomes dos arquivos ou a pasta mudarem, as barras antigas voltam ou faltam imagens. Vale reconferir `ManagerDeviceList.py` quando a versão mudar de 2.4.6.
- **Tamanho pequeno:** em 14 px de largura, um símbolo pode ficar ilegível. Se isso acontecer, usar só a barra e diferenciar pela cor.

**Para reverter:** remover o overlay de `modules/common.nix` e fazer o rebuild. O pacote original volta.
