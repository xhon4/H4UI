#!/usr/bin/env bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        instala la fuente Selawik (la que le da el look
# │                 Segoe/Win7 a todo). JetBrainsMono Nerd ya quedó
# │                 instalada como paquete en la fase anterior; acá solo
# │                 falta Selawik, que no tiene paquete instalable.
# │ PODÉS CAMBIAR: nada, es automático.
# │ NO TOQUES:     la ruta ~/.local/share/fonts/Selawik — fontconfig busca
# │                 fuentes ahí por convención, no inventes otra carpeta.
# │ VA EN:         scripts/20-fonts.sh (fase 2 del instalador)
# └──────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/log.sh"

step "Fuentes"

# 👉 El paquete ttf-selawik de AUR está roto (depende de algo que ya no
# existe), así que la bajamos directo del repo oficial de Microsoft.
SELAWIK_DIR="$HOME/.local/share/fonts/Selawik"

if [ -d "$SELAWIK_DIR" ] && [ -n "$(ls -A "$SELAWIK_DIR" 2>/dev/null)" ]; then
    info "Selawik ya está instalada en $SELAWIK_DIR, salteo la descarga."
elif is_dry_run; then
    info "(dry-run) descargaría Selawik (github.com/microsoft/Selawik, carpeta Fonts/) a $SELAWIK_DIR"
else
    info "Descargando Selawik..."
    mkdir -p "$SELAWIK_DIR"
    tmp_selawik="$(mktemp -d)"
    # 👉 sparse-checkout: bajamos SOLO la carpeta Fonts/, no el repo entero.
    git clone --depth=1 --filter=blob:none --sparse https://github.com/microsoft/Selawik.git "$tmp_selawik/Selawik"
    (cd "$tmp_selawik/Selawik" && git sparse-checkout set Fonts)
    find "$tmp_selawik/Selawik/Fonts" -maxdepth 1 -iname '*.ttf' -exec cp -f {} "$SELAWIK_DIR/" \;
    rm -rf "$tmp_selawik"
    info "Selawik instalada en $SELAWIK_DIR."
fi

if is_dry_run; then
    info "(dry-run) fc-cache -f"
else
    fc-cache -f >/dev/null
    info "fc-cache: listo."
fi

info "Fuentes: listo."
