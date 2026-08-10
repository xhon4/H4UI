#!/usr/bin/env bash
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        funciones de log compartidas (info/warn/error/step) con
# │                 colores, para que todos los pasos del instalador hablen
# │                 con la misma voz. También trae el chequeo de --dry-run
# │                 y si gum está instalado.
# │ PODÉS CAMBIAR: los códigos de color ANSI de más abajo, si querés otra
# │                 paleta en la terminal.
# │ NO TOQUES:     los nombres de las funciones (info, warn, error, step,
# │                 die, has_gum, is_dry_run) — el resto del instalador las
# │                 llama por ese nombre exacto.
# │ VA EN:         scripts/lib/log.sh (cada fase lo carga con "source")
# └──────────────────────────────────────────────────────

# 👉 códigos de color ANSI. Cambialos si querés otra paleta en terminal.
H4UI_C_INFO="\033[1;36m"   # cyan
H4UI_C_WARN="\033[1;33m"   # amarillo
H4UI_C_ERR="\033[1;31m"    # rojo
H4UI_C_STEP="\033[1;32m"   # verde
H4UI_C_RESET="\033[0m"

info()  { printf "${H4UI_C_INFO}[info]${H4UI_C_RESET}  %s\n" "$*"; }
warn()  { printf "${H4UI_C_WARN}[warn]${H4UI_C_RESET}  %s\n" "$*" >&2; }
error() { printf "${H4UI_C_ERR}[error]${H4UI_C_RESET} %s\n" "$*" >&2; }
step()  { printf "\n${H4UI_C_STEP}==> %s${H4UI_C_RESET}\n" "$*"; }

# Corta el script con un mensaje de error. Usalo para lo que NO tiene
# forma de seguir (ej. "no hay internet").
die() { error "$*"; exit 1; }

# 👉 true si gum está instalado — lo usamos para decidir si mostramos
# prompts lindos (elegir, confirmar) o caemos a un default sano sin
# preguntar nada (gum se instala recién en la fase 10-packages.sh).
has_gum() { command -v gum &>/dev/null; }

# H4UI_DRY_RUN=1 cuando el usuario corrió "./install.sh --dry-run".
# Con dry-run, ningún script debería tocar el disco de verdad.
: "${H4UI_DRY_RUN:=0}"
is_dry_run() { [ "$H4UI_DRY_RUN" = "1" ]; }
