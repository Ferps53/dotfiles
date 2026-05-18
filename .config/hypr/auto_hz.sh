#!/usr/bin/env fish

# Nome do seu monitor principal (laptop)
set MONITOR "eDP-1"

# Variável global para evitar que o comando seja rodado repetidas vezes sem necessidade
set -g ESTADO_ATUAL ""

function atualizar_energia
    # Lê os arquivos do sistema para checar se está na tomada (1) ou bateria (0)
    set STATUS_TOMADA (cat /sys/class/power_supply/*/online 2>/dev/null | head -n 1)

    # Extrai as informações atuais do monitor para manter resolução, escala e posição
    set MONITOR_INFO (hyprctl monitors -j | jq --arg name "$MONITOR" '.[] | select(.name == $name)')
    
    # Previne erros caso o monitor do laptop esteja desligado/fechado
    if test -z "$MONITOR_INFO"
        return
    end

    # Pega os valores atuais dinamicamente
    set WIDTH (echo "$MONITOR_INFO" | jq '.width')
    set HEIGHT (echo "$MONITOR_INFO" | jq '.height')
    set SCALE (echo "$MONITOR_INFO" | jq '.scale')
    set X_POS (echo "$MONITOR_INFO" | jq '.x')
    set Y_POS (echo "$MONITOR_INFO" | jq '.y')
    set POSITION "$X_POS"x"$Y_POS"

    if test "$STATUS_TOMADA" = "0"; and test "$ESTADO_ATUAL" != "0"
        set -g ESTADO_ATUAL "0"
        
        # BATERIA: Cai para 60Hz mantendo a posição e escala
        set RESOLUTION "$WIDTH"x"$HEIGHT"@60
        hyprctl keyword monitor "$MONITOR,$RESOLUTION,$POSITION,$SCALE"
        brightnessctl set 25%
        
        notify-send -t 2000 "Modo Bateria" "Tela: 60Hz | Brilho: 25% 🔋"
        
    else if test "$STATUS_TOMADA" = "1"; and test "$ESTADO_ATUAL" != "1"
        set -g ESTADO_ATUAL "1"
        
        # TOMADA: Sobe para 165Hz mantendo a posição e escala
        set RESOLUTION "$WIDTH"x"$HEIGHT"@165
        hyprctl keyword monitor "$MONITOR,$RESOLUTION,$POSITION,$SCALE"
        brightnessctl set 100%
        
        notify-send -t 2000 "Modo Tomada" "Tela: 165Hz | Brilho: 100% ⚡"
    end
end

# 1. Checa a energia assim que você faz login no Hyprland
atualizar_energia

# 2. Fica escutando mudanças de energia (plugar/desplugar) em tempo real
udevadm monitor --subsystem-match=power_supply | while read -r line
    sleep 0.5
    atualizar_energia
end
