#!/usr/bin/env bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        prende o apaga (toggle) la hoja de trucos en pantalla —
# │                 el cartel con todos los atajos de teclado (ventana
# │                 "cheatsheet" de eww). Apretás Super + / y aparece;
# │                 la apretás de nuevo y se cierra.
# │ PODÉS CAMBIAR: nada, es chiquito y hace una sola cosa.
# │ NO TOQUES:     el nombre "cheatsheet" — tiene que ser IDÉNTICO al
# │                 nombre de la ventana definida en eww.yuck
# │                 (defwindow cheatsheet ...). Si no coincide, eww no
# │                 la encuentra y el script no hace nada.
# │ VA EN:         ~/.config/hypr/scripts/cheatsheet.sh
# │                 (lo llama Super + / desde hyprland.lua)
# └──────────────────────────────────────────────────────
# r4chi-dotfiles · by occhi

set -euo pipefail

WINDOW="cheatsheet"   # 👉 nombre de la ventana eww que togglea este script

# "eww active-windows" lista las ventanas abiertas ahora mismo. Si
# "cheatsheet" aparece en esa lista, ya está abierta -> la cerramos.
# Si no aparece, está cerrada -> la abrimos.
if eww active-windows 2>/dev/null | grep -q "$WINDOW"; then
    eww close "$WINDOW"
else
    eww open "$WINDOW"
fi
