#!/usr/bin/env bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        habilita el único servicio systemd que necesita H4UI:
# │                 sddm (la pantalla de login). El resto (waybar, swaync,
# │                 hypridle, etc.) los arranca hyprland.lua solo al hacer
# │                 login — no son servicios systemd.
# │ PODÉS CAMBIAR: nada.
# │ NO TOQUES:     nada — es un solo comando, idempotente.
# │ VA EN:         scripts/50-services.sh (fase 5 del instalador)
# └──────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/log.sh"

step "Servicios del sistema"

if systemctl is-enabled sddm &>/dev/null; then
    info "sddm ya está habilitado, no hago nada."
elif is_dry_run; then
    info "(dry-run) sudo systemctl enable sddm"
else
    sudo systemctl enable sddm
    info "sddm habilitado (se usa desde el próximo reinicio)."
fi

info "Servicios: listo."
