#!/usr/bin/env bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        chequea (no configura, ya lo hizo la fase 3) que los
# │                 temas GTK/Kvantum/SDDM hayan quedado bien instalados.
# │                 No usamos gsettings/dconf para "setear" nada porque no
# │                 son confiables en una sesión Hyprland sin GNOME atrás
# │                 — GTK ya lee gtk-theme-name directo de settings.ini.
# │ PODÉS CAMBIAR: nada, son solo chequeos de lectura.
# │ NO TOQUES:     nada — este script no escribe archivos, solo avisa si
# │                 algo de la fase anterior no quedó donde debía.
# │ VA EN:         scripts/40-themes.sh (fase 4 del instalador)
# └──────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/log.sh"

step "Verificando temas"

check_file() {
    local path="$1" desc="$2"
    if [ -e "$path" ] || sudo test -e "$path" 2>/dev/null; then
        info "OK: $desc ($path)"
    else
        warn "FALTA: $desc ($path) — revisá la fase de copia (30-copy-configs.sh)."
    fi
}

# GTK: no seteamos nada acá, solo confirmamos que settings.ini haya
# quedado con gtk-theme-name=H4UI (eso es lo que activa el tema de verdad).
for f in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
    if [ -f "$f" ] && grep -q '^gtk-theme-name=H4UI' "$f"; then
        info "OK: $f tiene gtk-theme-name=H4UI"
    else
        warn "FALTA o mal seteado: $f (esperaba gtk-theme-name=H4UI)"
    fi
done

check_file "$HOME/.local/share/themes/H4UI/index.theme" "tema GTK H4UI"
check_file "$HOME/.config/Kvantum/H4UI/H4UI.kvconfig" "tema Kvantum H4UI"

# SDDM: hace falta el tema Y el .conf que lo activa — sin el .conf, SDDM
# ni se entera de que el tema existe y usa el gris de fábrica.
check_file "/usr/share/sddm/themes/h4ui-sddm/Main.qml" "tema SDDM h4ui-sddm"
if sudo test -f /etc/sddm.conf.d/10-h4ui-theme.conf 2>/dev/null \
    && sudo grep -q '^Current=h4ui-sddm' /etc/sddm.conf.d/10-h4ui-theme.conf 2>/dev/null; then
    info "OK: /etc/sddm.conf.d/10-h4ui-theme.conf activa el tema h4ui-sddm"
else
    warn "FALTA: /etc/sddm.conf.d/10-h4ui-theme.conf (o no dice Current=h4ui-sddm)"
fi

info "Verificación de temas: listo."
