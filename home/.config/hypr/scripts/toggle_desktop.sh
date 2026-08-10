#!/bin/bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        el "mostrar escritorio" (Super + D) — esconde todas las
# │                 ventanas del workspace actual mandándolas a un
# │                 workspace especial, y las trae de vuelta si lo tocás
# │                 de nuevo.
# │ PODÉS CAMBIAR: poco acá — como mucho, el nombre del workspace especial
# │                 ("special:desktop") si ya lo usás para otra cosa.
# │ NO TOQUES:     la lógica de STATE_FILE — es la que recuerda qué
# │                 ventanas esconder y a qué workspace devolverlas.
# │ VA EN:         ~/.config/hypr/scripts/toggle_desktop.sh
# └──────────────────────────────────────────────────────
# r4chi-dotfiles · by occhi

STATE_FILE="/tmp/hypr_hidden_state"
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

if [ -f "$STATE_FILE" ]; then
    while IFS='|' read -r addr ws; do
        hyprctl dispatch movetoworkspacesilent "$ws,address:$addr"
    done < "$STATE_FILE"
    rm "$STATE_FILE"
else
    hyprctl clients -j \
        | jq -r --argjson ws "$CURRENT_WS" \
            '.[] | select(.workspace.id == $ws) | "\(.address)|\(.workspace.id)"' \
        > "$STATE_FILE"

    while IFS='|' read -r addr ws; do
        hyprctl dispatch movetoworkspacesilent "special:desktop,address:$addr"
    done < "$STATE_FILE"
fi
