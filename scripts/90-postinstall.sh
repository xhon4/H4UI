#!/usr/bin/env bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        el mensaje final, con los próximos pasos para el
# │                 novato: reiniciar, dónde está la ayuda en pantalla, y
# │                 que existe "h4ui reset" por si algo se rompe.
# │ PODÉS CAMBIAR: el texto del mensaje si querés agregar algo.
# │ NO TOQUES:     nada importante — es solo un cartel.
# │ VA EN:         scripts/90-postinstall.sh (última fase del instalador)
# └──────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/log.sh"

step "¡Listo!"

MSG="H4UI está instalado.

Próximos pasos:
  1. Reiniciá la PC (para que arranque SDDM con el tema H4UI).
  2. En la pantalla de login, elegí la sesión Hyprland.
  3. Ya en el escritorio, apretá Super + / para ver TODOS los atajos en
     pantalla (el cheatsheet).
  4. ¿Rompiste algo? Corré:  h4ui reset
     (te devuelve tus configs originales, tal como estaban antes de instalar).

Comandos disponibles (h4ui help para el detalle):
  h4ui reset [componente]   -> deshace los cambios de H4UI
  h4ui update                -> trae la última versión del repo (git pull)
  h4ui cheatsheet             -> abre/cierra la ayuda en pantalla
  h4ui help                   -> esta lista"

if is_dry_run; then
    info "(dry-run) mostraría el mensaje final de bienvenida"
elif has_gum; then
    gum style --border rounded --padding "1 2" --border-foreground 212 "$MSG"
else
    printf '\n%s\n\n' "$MSG"
fi
