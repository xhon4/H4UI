#!/usr/bin/env bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        el punto de entrada del instalador. Corre las fases de
# │                 scripts/ en orden (paquetes, fuentes, copiar configs,
# │                 temas, servicios, mensaje final).
# │ PODÉS CAMBIAR: nada acá — si querés saltarte una fase puntual, corré
# │                 ese script de scripts/ directo (ej.
# │                 ./scripts/20-fonts.sh).
# │ NO TOQUES:     el orden de PHASES — cada fase asume que la anterior ya
# │                 corrió (ej. 30-copy-configs necesita que 10-packages ya
# │                 haya instalado kvantum, para poder buscar el H4UI.svg).
# │ VA EN:         install.sh, en la raíz del repo. Se corre con:
# │                   ./install.sh            (instala de verdad)
# │                   ./install.sh --dry-run  (muestra qué haría, sin tocar nada)
# └──────────────────────────────────────────────────────
set -euo pipefail

H4UI_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export H4UI_REPO_ROOT

H4UI_DRY_RUN=0
for arg in "$@"; do
    case "$arg" in
        --dry-run)
            H4UI_DRY_RUN=1
            ;;
        -h|--help)
            echo "Uso: ./install.sh [--dry-run]"
            echo "  --dry-run   muestra qué haría el instalador, sin cambiar nada."
            exit 0
            ;;
        *)
            echo "Opción desconocida: $arg" >&2
            echo "Uso: ./install.sh [--dry-run]" >&2
            exit 1
            ;;
    esac
done
export H4UI_DRY_RUN

# shellcheck source=scripts/lib/log.sh
source "$H4UI_REPO_ROOT/scripts/lib/log.sh"

printf '\n'
printf '  ╔════════════════════════════════════════════╗\n'
printf '  ║   H4UI — instalador (Frutiger Aero rice)    ║\n'
printf '  ╚════════════════════════════════════════════╝\n\n'

if is_dry_run; then
    warn "Modo --dry-run: NO se va a cambiar nada, solo se muestra qué haría cada fase."
fi

# 👉 el orden importa: cada número es una fase, y se corren de menor a
# mayor. Ver la cajita de arriba antes de reordenar esto.
PHASES=(
    00-preflight.sh
    10-packages.sh
    20-fonts.sh
    30-copy-configs.sh
    40-themes.sh
    50-services.sh
    90-postinstall.sh
)

# gum recién existe después de 10-packages.sh, así que esta confirmación
# inicial solo aparece si ya lo tenías instalado de antes. Si no, seguimos
# directo sin preguntar (default sano, instalador no-interactivo).
if has_gum && ! is_dry_run; then
    gum confirm "¿Arrancamos la instalación de H4UI?" || { info "Cancelado, no se cambió nada."; exit 0; }
fi

for phase in "${PHASES[@]}"; do
    bash "$H4UI_REPO_ROOT/scripts/$phase"
done
