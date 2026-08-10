#!/usr/bin/env bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        los chequeos previos a instalar: ¿es Arch?, ¿hay
# │                 internet?, ¿la placa de video es AMD?, ¿NO estás
# │                 corriendo esto como root?
# │ PODÉS CAMBIAR: nada — son controles de seguridad, no configuración.
# │ NO TOQUES:     el orden (Arch e internet cortan la instalación si
# │                 fallan; la GPU solo avisa y sigue).
# │ VA EN:         scripts/00-preflight.sh (fase 0 del instalador)
# └──────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/log.sh"

step "Chequeos previos"

# 1) ¿Sos root? NO corras esto como root ni con sudo: $HOME dejaría de ser
#    tu carpeta, y el script pide sudo solito cuando de verdad lo necesita.
if [ "$(id -u)" -eq 0 ]; then
    die "No corras install.sh como root (ni con sudo). El script pide sudo solo cuando hace falta."
fi

# 2) ¿Es Arch Linux? (o un derivado que tenga pacman)
if ! command -v pacman &>/dev/null; then
    die "No encontré 'pacman'. H4UI está pensado para Arch Linux (o derivados con pacman)."
fi
info "pacman encontrado: OK, esto es Arch (o derivado)."

# 3) ¿Hay internet? Hace falta para pacman, AUR y para bajar fuentes.
if command -v curl &>/dev/null; then
    if ! curl -fsS --max-time 5 https://archlinux.org &>/dev/null; then
        die "No hay conexión a internet (o archlinux.org no responde). Conectate y volvé a correr install.sh."
    fi
else
    if ! ping -c 1 -W 5 archlinux.org &>/dev/null; then
        die "No hay conexión a internet (o archlinux.org no responde). Conectate y volvé a correr install.sh."
    fi
fi
info "Internet: OK."

# 4) GPU AMD (Vega 7/8) — esto es un AVISO, no corta la instalación.
#    H4UI se armó y probó en AMD; en otra placa puede andar igual, pero
#    sobre todo el blur/vibrancy puede necesitar ajustes (más en NVIDIA).
if command -v lspci &>/dev/null; then
    if lspci | grep -Ei 'vga|3d|display' | grep -qi 'amd\|advanced micro devices'; then
        info "GPU AMD detectada: OK."
    else
        warn "No detecté una GPU AMD. H4UI se probó en AMD (Vega); en otra placa puede necesitar ajustes (blur, drivers)."
    fi
else
    warn "No encontré 'lspci', no puedo chequear la GPU. Seguimos igual."
fi

info "Preflight completo."
