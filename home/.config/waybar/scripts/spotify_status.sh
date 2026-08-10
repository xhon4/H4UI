#!/bin/bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        arma el texto que muestra waybar en el módulo de
# │                 Spotify (artista - canción, o "No Music" si no suena
# │                 nada), leyendo el estado con playerctl.
# │ PODÉS CAMBIAR: MAXLEN (largo del texto antes de cortar con "...") y
# │                 los textos entre comillas ("No Music :c", etc.).
# │ NO TOQUES:     el nombre "spotify" que busca con grep — si lo cambiás,
# │                 el script deja de encontrar el reproductor.
# │ VA EN:         ~/.config/waybar/scripts/spotify_status.sh
# │                 (lo llama el módulo "custom/spotify" de config.jsonc)
# └──────────────────────────────────────────────────────
# r4chi-dotfiles · by occhi

MAXLEN=40   # 👉 cuántos caracteres de "Artista - Canción" mostrar antes de cortar

player=$(playerctl --list-all 2>/dev/null | grep -i "spotify" | head -n1 | tr -d '[:space:]')

if [ -z "$player" ]; then
    echo '{"text": "󰝛  No Music :c", "class": "stopped", "tooltip": ""}'
    exit
fi

status=$(playerctl --player="$player" status 2>/dev/null)

if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
    artist=$(playerctl --player="$player" metadata artist 2>/dev/null)
    title=$(playerctl --player="$player" metadata title 2>/dev/null)

    if [ -z "$title" ] || [ -z "$artist" ]; then
        echo '{"text": "󰝛 No Music :c", "class": "stopped", "tooltip": ""}'
        exit
    fi

    full="$artist - $title"
    if [ ${#full} -gt $MAXLEN ]; then
        full="${full:0:$MAXLEN}..."
    fi

    prev=""
    next=""

    class="playing"
    [ "$status" == "Paused" ] && class="paused"

    text_escaped=$(echo "$prev   $full   $next" | sed 's/"/\\"/g')
    tooltip_escaped=$(echo "$full" | sed 's/"/\\"/g')

    echo "{\"text\": \"$text_escaped\", \"class\": \"$class\", \"tooltip\": \"$tooltip_escaped\"}"
else
    echo '{"text": "󰝛 No Music :c", "class": "stopped", "tooltip": ""}'
fi
