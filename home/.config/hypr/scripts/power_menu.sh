#!/bin/bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        el menú de apagado/reiniciar/bloquear/salir que se abre
# │                 con Super + BackSpace (le pasa las opciones a rofi).
# │ PODÉS CAMBIAR: los textos/iconos del menú (options) y qué comando
# │                 corre cada opción, dentro del case de más abajo.
# │ NO TOQUES:     los nombres exactos entre comillas del case — tienen
# │                 que ser IDÉNTICOS a los de "options", si no rofi
# │                 no va a reconocer qué elegiste.
# │ VA EN:         ~/.config/hypr/scripts/power_menu.sh
# └──────────────────────────────────────────────────────
# r4chi-dotfiles · by occhi

options="󰍁 Lock
󰒲 Suspend
󰗽 Logout
󰜉 Reboot
󰐥 Shutdown"

rofi_cmd() {
    rofi -dmenu \
        -p "Goodbye ${USER}" \
        -mesg "Uptime: $(uptime -p | sed 's/up //')" \
        -theme "$HOME/.config/rofi/PowerMenu.rasi"
}

chosen=$(printf "%s\n" "$options" | rofi_cmd)

case "$chosen" in
    "󰐥 Shutdown") systemctl poweroff ;;
    "󰜉 Reboot")   systemctl reboot ;;
    "󰍁 Lock")     loginctl lock-session ;;
    "󰒲 Suspend")  systemctl suspend ;;
    "󰗽 Logout")   hyprctl dispatch exit ;;
esac
