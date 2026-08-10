#!/usr/bin/env bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        antes de que install.sh pise un archivo tuyo, esto guarda
# │                 una copia en ~/.local/share/h4ui/backup/. Es la red de
# │                 contención: "h4ui reset" usa esa copia para devolverte
# │                 TODO tal como estaba antes de instalar H4UI.
# │ PODÉS CAMBIAR: nada, es el corazón del "h4ui reset" (§0.3 del plan).
# │ NO TOQUES:     el formato del manifest.tsv (dos columnas separadas por
# │                 TAB: ruta-destino, ruta-del-backup) — "h4ui reset" lo
# │                 lee así, y NO depende de este repo para hacerlo (por
# │                 eso el formato tiene que quedar estable).
# │ VA EN:         scripts/lib/backup.sh (lo carga 30-copy-configs.sh)
# └──────────────────────────────────────────────────────
# Requiere que scripts/lib/log.sh ya esté cargado (usa info() e is_dry_run()).

H4UI_BACKUP_DIR="${H4UI_BACKUP_DIR:-$HOME/.local/share/h4ui/backup}"
H4UI_MANIFEST="$H4UI_BACKUP_DIR/manifest.tsv"

# ¿el path está fuera de $HOME? (o sea, es de /usr o /etc y hace falta sudo
# para leerlo/copiarlo). 0 = sí necesita sudo, 1 = no.
_h4ui_needs_sudo() {
    case "$1" in
        "$HOME"/*) return 1 ;;
        *) return 0 ;;
    esac
}

# ¿ya está anotado este destino en el manifest? Si ya lo respaldamos una
# vez (ej. en una instalación anterior de H4UI), NO lo volvemos a respaldar
# — si no, terminaríamos "respaldando" nuestra propia copia de H4UI en vez
# del archivo original tuyo, y "h4ui reset" dejaría de servir para algo.
_h4ui_already_backed_up() {
    [ -f "$H4UI_MANIFEST" ] || return 1
    grep -qF "$(printf '%s\t' "$1")" "$H4UI_MANIFEST"
}

# backup_if_exists <ruta-destino-absoluta>
#
# Si ese archivo ya existe (es algo que vamos a pisar) y todavía no lo
# respaldamos, lo copia a:
#   ~/.local/share/h4ui/backup/<la-misma-ruta-sin-la-barra-inicial>
# y anota el par (destino, backup) en el manifest. Si el archivo no existe
# todavía, no hay nada que respaldar y no hace nada.
backup_if_exists() {
    local dest="$1"

    { [ -e "$dest" ] || [ -L "$dest" ] || sudo test -e "$dest" 2>/dev/null; } || return 0
    _h4ui_already_backed_up "$dest" && return 0

    local backup_path="$H4UI_BACKUP_DIR/${dest#/}"

    if is_dry_run; then
        info "(dry-run) respaldaría $dest -> $backup_path"
        return 0
    fi

    mkdir -p "$(dirname "$backup_path")"

    if _h4ui_needs_sudo "$dest"; then
        sudo cp -a "$dest" "$backup_path"
        sudo chown "$(id -u):$(id -g)" "$backup_path"
    else
        cp -a "$dest" "$backup_path"
    fi

    mkdir -p "$(dirname "$H4UI_MANIFEST")"
    printf '%s\t%s\n' "$dest" "$backup_path" >> "$H4UI_MANIFEST"
}
