# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        El cerebro de tu terminal con menú interactivo activado.
# │ PODÉS CAMBIAR: Los atajos (alias) que usás todos los días.
# │ NO TOQUES:     El bloque de "zstyle", es magia negra para el autocompletado.
# └──────────────────────────────────────────────────────

fastfetch
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# 👉 ALIAS H4UI
alias ll='ls -lh --color=auto'
alias la='ls -lAh --color=auto'
alias update='h4ui update'
alias c='clear'

setopt AUTO_CD
setopt CORRECT

# 👉 Menú interactivo Aero: apretá TAB para elegir opciones con las flechitas
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''

eval "$(starship init zsh)"