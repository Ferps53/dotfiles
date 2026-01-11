#!/bin/bash

# ================= CONFIGURAÇÃO =================
# Digite 'hyprctl monitors' no terminal para descobrir o nome.
# Exemplos comuns: eDP-1, DP-1, HDMI-A-1
MONITOR_NAME="eDP-1" 
# ================================================

# Verifica se o monitor existe e pega as infos em JSON
MONITOR_INFO=$(hyprctl monitors -j | jq --arg name "$MONITOR_NAME" '.[] | select(.name == $name)')

if [ -z "$MONITOR_INFO" ]; then
    notify-send "Erro" "Monitor $MONITOR_NAME não encontrado." -u critical
    exit 1
fi

# Extrai as informações atuais para manter resolução, escala e posição
WIDTH=$(echo "$MONITOR_INFO" | jq '.width')
HEIGHT=$(echo "$MONITOR_INFO" | jq '.height')
SCALE=$(echo "$MONITOR_INFO" | jq '.scale')
X_POS=$(echo "$MONITOR_INFO" | jq '.x')
Y_POS=$(echo "$MONITOR_INFO" | jq '.y')
CURRENT_RATE=$(echo "$MONITOR_INFO" | jq '.refreshRate')

# Arredonda o refresh rate atual para um número inteiro (ex: 164.98 -> 164)
CURRENT_RATE_INT=${CURRENT_RATE%.*}

# Lógica de alternância
if [ "$CURRENT_RATE_INT" -ge 100 ]; then
    NEW_RATE=60
else
    NEW_RATE=165
fi

# Aplica a nova configuração
# Sintaxe: monitor=NAME,RES@HZ,POS,SCALE
hyprctl keyword monitor "$MONITOR_NAME,${WIDTH}x${HEIGHT}@${NEW_RATE},${X_POS}x${Y_POS},${SCALE}"

# Envia notificação (Requer libnotify/dunst/swaync)
notify-send "Display" "Taxa de atualização alterada para ${NEW_RATE}Hz" -i video-display
