#!/usr/bin/env bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        instala todos los paquetes: primero gum (a pelo, sin
# │                 preguntar nada, porque todavía no está para preguntar),
# │                 después el resto de los oficiales (pacman, una sola
# │                 transacción), y por último los de AUR (compilando
# │                 "paru" primero si no lo tenés).
# │ PODÉS CAMBIAR: si algún día sumás una app nueva al rice y necesita un
# │                 paquete, agregalo a OFFICIAL_PACKAGES o AUR_PACKAGES.
# │ NO TOQUES:     el orden (gum primero, solo; el resto de oficiales
# │                 después; AUR al final) — depende de sí mismo.
# │ VA EN:         scripts/10-packages.sh (fase 1 del instalador)
# └──────────────────────────────────────────────────────
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/log.sh"

step "Paquetes oficiales + AUR"

run_pacman() {
    if is_dry_run; then
        info "(dry-run) sudo pacman -S --needed --noconfirm $*"
    else
        sudo pacman -S --needed --noconfirm "$@"
    fi
}

# ── Paso 0: gum, solo, a pelo ───────────────────────────────────────────
# 👉 gum es el que da los menús lindos (elegir perfil, confirmar apps
# opcionales) pero el instalador lo necesita ANTES de poder usarlo para
# preguntar nada — huevo y gallina. Por eso va primero, sin preguntar nada.
if ! command -v gum &>/dev/null; then
    info "Instalando gum (para los menús interactivos)..."
    run_pacman gum
fi

# ── Paquetes oficiales (repo, sin AUR) ──────────────────────────────────
# 👉 Esta es la lista completa que arma H4UI. Si le sumás una app al
# rice más adelante y necesita un paquete nuevo, agregalo acá.
#
# Nota: "fontconfig", "pipewire"/"pipewire-pulse"/"pipewire-alsa"/
# "wireplumber" y "git"/"base-devel" NO estaban en la lista original —
# se agregaron porque hacen falta para que el resto funcione de verdad
# (ver el informe de instalación para el detalle de cada uno).
OFFICIAL_PACKAGES=(
    hyprland hyprlock hypridle waybar rofi alacritty zsh starship swaync
    awww sddm papirus-icon-theme ttf-jetbrains-mono-nerd hyprpolkitagent
    network-manager-applet blueman pavucontrol udiskie brightnessctl
    playerctl grim slurp swappy cliphist wl-clipboard swayosd nautilus
    fastfetch jq qt5ct qt6ct kvantum kvantum-qt5 gum python polkit
    fontconfig
    # 👉 Módulos Qt6 que el tema SDDM h4ui-sddm NECESITA para renderizar y
    # que sddm NO arrastra como dependencia: qt6-5compat (el DropShadow del
    # panel de vidrio), qt6-svg (los íconos .svgz de apagar/reiniciar) y
    # qt6-virtualkeyboard (lo carga un Loader del tema aunque el teclado en
    # pantalla esté apagado). Sin estos, SDDM arranca en blanco o con el
    # tema gris de fábrica en una máquina recién instalada.
    qt6-5compat qt6-svg qt6-virtualkeyboard
    pipewire pipewire-pulse pipewire-alsa wireplumber
    git base-devel
)

step "Instalando paquetes oficiales (pacman)"
run_pacman "${OFFICIAL_PACKAGES[@]}"

# ── Perfil completo / mínimo ────────────────────────────────────────────
# 👉 Por ahora esto es solo informativo: instalamos siempre el set de
# arriba completo (es la única lista que tenemos). El día que armes un
# subconjunto real para "mínimo", este es el lugar para filtrar el array.
if has_gum && ! is_dry_run; then
    gum choose --header "Elegí un perfil (por ahora no cambia qué se instala):" "Completo" "Mínimo" >/dev/null || true
fi

# ── AUR: bootstrap de paru si falta ─────────────────────────────────────
if ! command -v paru &>/dev/null; then
    step "No encontré 'paru', lo compilo (lo necesitan bibata-cursor-theme-bin, bemoji, eww)"
    if is_dry_run; then
        info "(dry-run) clonaría y compilaría paru desde AUR"
    else
        tmp_paru="$(mktemp -d)"
        git clone --depth=1 https://aur.archlinux.org/paru.git "$tmp_paru/paru"
        (cd "$tmp_paru/paru" && makepkg -si --noconfirm)
        rm -rf "$tmp_paru"
    fi
else
    info "paru ya está instalado."
fi

# ── Paquetes AUR ─────────────────────────────────────────────────────────
AUR_PACKAGES=(bibata-cursor-theme-bin bemoji eww)
step "Instalando paquetes AUR"
if is_dry_run; then
    info "(dry-run) paru -S --needed --noconfirm ${AUR_PACKAGES[*]}"
else
    paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"
fi

# ── App opcional: gcalcli (AUR, no está en el repo oficial) ─────────────
# Le suma el calendario de Google al tooltip del reloj de waybar
# (clock_calendar.sh). Si decís que no —o si falla la instalación—, el
# script ya está preparado (chequea con shutil.which) para seguir andando
# bien sin él. Por eso "|| warn ...": un opcional roto NUNCA debe tirar
# abajo el resto del instalador (esto reventó una instalación real antes
# de que lo arregláramos — no lo repitamos).
INSTALL_GCALCLI=0
if has_gum; then
    if gum confirm "¿Instalar gcalcli (calendario de Google en el reloj de waybar)?"; then
        INSTALL_GCALCLI=1
    fi
else
    warn "gum no está disponible todavía; salteo gcalcli por default (después: paru -S gcalcli)."
fi
if [ "$INSTALL_GCALCLI" = "1" ]; then
    step "Instalando gcalcli (opcional, AUR)"
    if is_dry_run; then
        info "(dry-run) paru -S --needed --noconfirm gcalcli"
    else
        paru -S --needed --noconfirm gcalcli \
            || warn "No se pudo instalar gcalcli. No pasa nada: el reloj de waybar sigue andando sin calendario."
    fi
fi

info "Paquetes: listo."
