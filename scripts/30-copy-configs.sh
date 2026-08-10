#!/usr/bin/env bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        la fase que de verdad instala H4UI en tu sistema:
# │                 copia (NO symlinkea) home/ -> $HOME, usr/ -> /usr,
# │                 system/ -> /, los temas GTK/Kvantum, y el CLI "h4ui".
# │                 Antes de pisar cualquier archivo tuyo, lo respalda
# │                 (scripts/lib/backup.sh) para que "h4ui reset" funcione.
# │ PODÉS CAMBIAR: nada acá adentro — si querés agregar/sacar QUÉ se
# │                 instala, la fuente de verdad es la carpeta home/, usr/,
# │                 system/ o theme/, no este script.
# │ NO TOQUES:     la lógica de "force" vs "no-clobber" — usr/ trae assets
# │                 de fábrica de sddm que NO hay que pisar, salvo las
# │                 rutas H4UI-specific que sí se fuerzan a propósito.
# │ VA EN:         scripts/30-copy-configs.sh (fase 3 del instalador)
# └──────────────────────────────────────────────────────
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/backup.sh"

: "${H4UI_REPO_ROOT:?H4UI_REPO_ROOT no está seteado — corré esto vía install.sh, no suelto.}"

step "Copiando configs"

# copy_file <origen> <destino> <sudo:si|no> <force:si|no>
#
# force=si  -> siempre pisa el destino (con backup antes de pisar).
# force=no  -> semántica "cp -n": si el destino YA existe, no lo toca
#              (lo usamos para usr/, que trae archivos de fábrica del
#              paquete sddm que no son nuestros — no hay que pisarlos).
copy_file() {
    local src="$1" dest="$2" needs_sudo="$3" force="$4"

    if is_dry_run; then
        if [ "$force" = "no" ]; then
            info "(dry-run) copiaría $src -> $dest (solo si NO existe ya)"
        else
            info "(dry-run) copiaría $src -> $dest (con backup si hace falta)"
        fi
        return 0
    fi

    if [ "$needs_sudo" = "si" ]; then
        sudo mkdir -p "$(dirname "$dest")"
        if [ "$force" = "no" ] && sudo test -e "$dest"; then
            return 0
        fi
        backup_if_exists "$dest"
        sudo cp -f "$src" "$dest"
    else
        mkdir -p "$(dirname "$dest")"
        if [ "$force" = "no" ] && [ -e "$dest" ]; then
            return 0
        fi
        backup_if_exists "$dest"
        cp -f "$src" "$dest"
    fi
}

# copy_tree <carpeta-origen> <prefijo-destino> <sudo:si|no> <force:si|no>
#
# Recorre TODOS los archivos bajo carpeta-origen y los copia a
# prefijo-destino, preservando la sub-estructura de carpetas tal cual.
copy_tree() {
    local src_root="$1" dest_prefix="${2%/}" needs_sudo="$3" force="$4"
    [ -d "$src_root" ] || { warn "No existe $src_root, salteo."; return 0; }

    while IFS= read -r -d '' file; do
        local rel="${file#"$src_root"/}"
        copy_file "$file" "$dest_prefix/$rel" "$needs_sudo" "$force"
    done < <(find "$src_root" -type f -print0)
}

# ── home/ -> $HOME ───────────────────────────────────────────────────────
# Todo lo de home/ es nuestro (H4UI-specific), así que se fuerza siempre.
step "home/ -> \$HOME"
copy_tree "$H4UI_REPO_ROOT/home" "$HOME" no si

# ── usr/ -> /usr (con sudo) ──────────────────────────────────────────────
# usr/ trae de todo: nuestro tema SDDM Y también assets de fábrica del
# paquete sddm (flags, temas elarun/maldives/maya, etc.) que están acá
# solo de referencia — el paquete real ya los instala. Por eso copiamos
# TODO el árbol sin pisar lo que ya exista (cp -n), y después forzamos
# SOLO las 2 rutas que son de verdad nuestras.
step "usr/ -> /usr (con sudo)"
copy_tree "$H4UI_REPO_ROOT/usr" "/usr" si no
copy_file "$H4UI_REPO_ROOT/usr/share/backgrounds/bloq.png" "/usr/share/backgrounds/bloq.png" si si
copy_tree "$H4UI_REPO_ROOT/usr/share/sddm/themes/h4ui-sddm" "/usr/share/sddm/themes/h4ui-sddm" si si

# ── system/ -> / (con sudo) ──────────────────────────────────────────────
# Tercer árbol espejo (además de home/ y usr/): mapea a la raíz "/", para
# lo poco que va en /etc (ver DEVELOPMENT.md §3). Todo acá es nuestro.
step "system/ -> / (con sudo)"
copy_tree "$H4UI_REPO_ROOT/system" "/" si si

# ── Tema GTK -> ~/.local/share/themes/H4UI ───────────────────────────────
step "Tema GTK -> ~/.local/share/themes/H4UI"
copy_tree "$H4UI_REPO_ROOT/theme/gtk/H4UI" "$HOME/.local/share/themes/H4UI" no si

# ── Tema Kvantum -> ~/.config/Kvantum/H4UI ───────────────────────────────
step "Tema Kvantum -> ~/.config/Kvantum/H4UI"
copy_file "$H4UI_REPO_ROOT/theme/kvantum/H4UI/H4UI.kvconfig" "$HOME/.config/Kvantum/H4UI/H4UI.kvconfig" no si

# El tema H4UI de Kvantum es un recolor del tema base "Kvantum" que trae
# el propio motor Kvantum, y necesita el H4UI.svg de ese tema base al
# lado del .kvconfig. Ese SVG NO está versionado en el repo (es un asset
# de terceros) — lo buscamos recién ahora porque recién en la fase 10 se
# instalaron los paquetes kvantum/kvantum-qt5 que lo traen.
step "Kvantum: buscando el H4UI.svg base (asset de terceros)"
KVANTUM_DEST_SVG="$HOME/.config/Kvantum/H4UI/H4UI.svg"
if is_dry_run; then
    info "(dry-run) buscaría un kvantum.svg bajo /usr/share/Kvantum y lo copiaría a $KVANTUM_DEST_SVG"
else
    kvantum_svg_src="$(find /usr/share/Kvantum -maxdepth 2 -iname 'kvantum.svg' 2>/dev/null | head -n1)"
    if [ -n "$kvantum_svg_src" ]; then
        mkdir -p "$(dirname "$KVANTUM_DEST_SVG")"
        cp -f "$kvantum_svg_src" "$KVANTUM_DEST_SVG"
        info "H4UI.svg copiado desde $kvantum_svg_src"
    else
        warn "No encontré el H4UI.svg base del tema Kvantum (busqué bajo /usr/share/Kvantum)."
        warn "El recolor de Kvantum puede no renderizar bien. Revisá a mano que kvantum/kvantum-qt5 estén instalados."
    fi
fi

# ── Permisos de ejecución en los scripts copiados ────────────────────────
step "Permisos de ejecución en scripts"
if is_dry_run; then
    info "(dry-run) chmod +x en ~/.config/hypr/scripts/*.sh y ~/.config/waybar/scripts/*.sh"
else
    chmod +x "$HOME"/.config/hypr/scripts/*.sh 2>/dev/null || true
    chmod +x "$HOME"/.config/waybar/scripts/*.sh 2>/dev/null || true
    # 👉 el cheatsheet en particular, explícito: git no siempre conserva
    # el bit +x al clonar, y sin esto Super + / no hace nada.
    chmod +x "$HOME/.config/hypr/scripts/cheatsheet.sh" 2>/dev/null || true
fi

# ── El CLI h4ui -> ~/.local/bin/h4ui ──────────────────────────────────────
step "Instalando el CLI h4ui"
H4UI_BIN_DEST="$HOME/.local/bin/h4ui"
if is_dry_run; then
    info "(dry-run) copiaría scripts/h4ui -> $H4UI_BIN_DEST y anotaría de dónde clonaste el repo"
else
    mkdir -p "$HOME/.local/bin"
    backup_if_exists "$H4UI_BIN_DEST"
    cp -f "$H4UI_REPO_ROOT/scripts/h4ui" "$H4UI_BIN_DEST"
    chmod +x "$H4UI_BIN_DEST"

    # "h4ui update" necesita saber dónde clonaste el repo. Lo anotamos acá
    # (no depende de que el repo siga estando: si lo borraste, "update"
    # simplemente te va a avisar que te falta re-clonarlo).
    mkdir -p "$HOME/.local/share/h4ui"
    printf '%s\n' "$H4UI_REPO_ROOT" > "$HOME/.local/share/h4ui/install-source.txt"
fi

# ── ~/.local/bin en el PATH ───────────────────────────────────────────────
# 👉 Esto es algo de TU sistema (dónde busca comandos la terminal), no del
# look del rice — por eso se toca el .zshrc YA COPIADO en $HOME, y no el
# home/.zshrc del repo (ese es el default "de fábrica" de H4UI).
step "Verificando que ~/.local/bin esté en el PATH"
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ] && grep -q '\.local/bin' "$ZSHRC"; then
    info "~/.local/bin ya está en el PATH, no toco nada."
elif [ ! -f "$ZSHRC" ]; then
    warn "No encontré $ZSHRC todavía, no puedo chequear/agregar el PATH."
elif is_dry_run; then
    info "(dry-run) agregaría ~/.local/bin al PATH en $ZSHRC"
else
    {
        echo ''
        echo '# 👉 H4UI agregó esto para que el comando "h4ui" se encuentre solo.'
        echo '# Es un tema de TU sistema (dónde busca comandos la terminal), no'
        echo '# del look del rice — por eso se agrega acá y no en el .zshrc del repo.'
        echo 'export PATH="$HOME/.local/bin:$PATH"'
    } >> "$ZSHRC"
    info "Agregado ~/.local/bin al PATH en $ZSHRC"
fi

info "Copia de configs: listo."
