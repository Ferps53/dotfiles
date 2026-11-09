#!/usr/bin/env fish

# ================= CONFIGURAÇÃO =================
# Digite 'hyprctl monitors' no terminal para descobrir o nome.
# Exemplos comuns: eDP-1, DP-1, HDMI-A-1
set MONITOR_NAME "eDP-1" 
# ================================================

# Verifica se o monitor existe e pega as infos em JSON
set MONITOR_INFO (hyprctl monitors -j | jq --arg name "$MONITOR_NAME" '.[] | select(.name == $name)')

if test -z "$MONITOR_INFO"
    notify-send "Erro" "Monitor $MONITOR_NAME não encontrado." -u critical
    exit 1
end

# Extrai as informações atuais para manter resolução, escala e posição
set WIDTH (echo "$MONITOR_INFO" | jq '.width')
set HEIGHT (echo "$MONITOR_INFO" | jq '.height')
set SCALE (echo "$MONITOR_INFO" | jq '.scale')
set X_POS (echo "$MONITOR_INFO" | jq '.x')
set Y_POS (echo "$MONITOR_INFO" | jq '.y')
set CURRENT_RATE (echo "$MONITOR_INFO" | jq '.refreshRate')

# Arredonda o refresh rate atual para um número inteiro separando pelo ponto
set CURRENT_RATE_INT (string split -f1 '.' $CURRENT_RATE)

# Lógica de alternância
if test $CURRENT_RATE_INT -ge 100
    set NEW_RATE 60
else
    set NEW_RATE 165
end

# Monta as strings para evitar problemas de concatenação no Fish
set RESOLUTION "$WIDTH"x"$HEIGHT"@"$NEW_RATE"
set POSITION "$X_POS"x"$Y_POS"

# Aplica a nova configuração
# Sintaxe: monitor=NAME,RES@HZ,POS,SCALE
hyprctl keyword monitor "$MONITOR_NAME,$RESOLUTION,$POSITION,$SCALE"

# Envia notificação
notify-send "Display" "Taxa de atualização alterada para "$NEW_RATE"Hz" -i video-display
