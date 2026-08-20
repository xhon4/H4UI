# H4UI — Plan de desarrollo

> **Nota de estado (2026-08-10):** dos cosas de este plan quedaron desactualizadas apenas
> empezamos a construir en serio:
> - **§1 Paleta base** — los valores de acá abajo NO son los finales. La paleta real, la que
>   se probó en pantalla y se mantiene como fuente de verdad, vive en
>   [`theme/colors/palette.toml`](theme/colors/palette.toml). Este documento queda como mapa
>   general, no como referencia de color.
> - **§2 Stack final** — dice `swww` para el wallpaper. `swww` fue archivado; lo reemplaza
>   `awww` (mismo autor, sucesor directo). Los configs ya usan `awww` / `awww-daemon`.
> - **§3 / §7 ricectl** — el ricectl que este plan daba por sentado (instalador manifest-driven)
>   se perdió. El linkeo de configs se resuelve con un script bash simple (`install.sh` recorre
>   `home/` y lo pasa a `$HOME`), no con un manifest propio. Ver el bullet de abajo para el
>   mecanismo exacto (copia, no symlink).
> - **§3 instalador (actualizado, decisión de diseño)** — `install.sh` NO symlinkea, **copia**.
>   Así podés borrar la carpeta clonada del repo entero después de instalar y el escritorio
>   sigue andando 100%. `h4ui reset` no depende del repo tampoco: restaura desde los backups
>   que `install.sh` hizo ANTES de pisar cada archivo (`~/.local/share/h4ui/backup/`).
> - **§3 estructura — `system/`** — se sumó un tercer árbol espejo, `system/`, que mapea a
>   `/` (para lo poco que va en `/etc`, ej. `system/etc/sddm.conf.d/10-h4ui-theme.conf`).
>   Mismo criterio que `usr/`: `install.sh` lo copia con sudo. No estaba en el plan original.
> - **§0.3 / §7 `h4ui reset` — ELIMINADO (2026-08-20)** — la red de contención por backups
>   se sacó a propósito: el instalador ahora **reemplaza directo** (deploy limpio, listo para
>   usar al reboot). Ya no se hacen backups, no existe `h4ui reset` ni `scripts/lib/backup.sh`;
>   el CLI `h4ui` quedó con `update`, `cheatsheet` y `help`. Las menciones sueltas de `reset`
>   más abajo (§0.3, §3, §5, §7, §8) son historia del plan, superadas por esta nota.
> - **§1 / §2 prompt de terminal** — el plan usa Starship (§2 descartó p10k a propósito). Ver
>   más abajo si esa decisión cambia.

Ricing **Frutiger Aero** (inspirado en Windows 7, **no clon**) para deployar en la PC de un
principiante total de Linux. El rice cumple doble función: **verse increíble** y **enseñar a usar
el sistema**. Todo se construye primero en tu PC y después se pasa a un repo.

> **Cómo usar este doc:** leelo de arriba a abajo una vez para tener el mapa. Después, para
> construir, pasale a Claude Code **una fase por vez** (sección 5). No le tires todo junto:
> cada fase es un bloque autocontenido pensado para un prompt.

---

## 0. Principios de diseño (no negociables)

1. **Teaching-first.** Cada archivo de config lleva comentarios humanos en español (ver §6 y
   apéndice). Si hay que elegir entre "elegante" y "entendible por un novato", gana entendible.
2. **Frutiger Aero, no Win7.** Nos inspiramos en el *espíritu* (vidrio, agua, transparencias de
   colores, verde-lima, gloss, animaciones fluidas), no copiamos la UI de Windows.
3. **Red de contención.** El pibe va a romper cosas aprendiendo. Todo tiene default seguro y
   `h4ui reset` para volver atrás.
4. **Un solo source of truth de color.** `theme/colors/palette.toml`. Todo lo demás sale de ahí.
5. **Hardware AMD (Vega 7/8).** Cero drama de drivers; blur y animaciones andan fluido. Se copia
   tu perfil de tuning casi tal cual.

---

## 1. Design system (tokens)

### Paleta base (`theme/colors/palette.toml`)

| Token         | Valor                          | Uso                                  |
|---------------|--------------------------------|--------------------------------------|
| `aqua`        | `#29ABE2`                      | acento primario                      |
| `sky`         | `#6FD3FF`                      | highlights, hover                    |
| `deep`        | `#0B5FA5`                      | bordes, texto sobre vidrio           |
| `leaf`        | `#8CC63F`                      | acento secundario / "ok"             |
| `lime`        | `#B4E05A`                      | glows y detalles                     |
| `ink`         | `#0A2A3F`                      | texto principal                      |
| `glass-white` | `rgba(255,255,255,0.30)`       | base del vidrio                      |
| `gloss-top`   | `rgba(255,255,255,0.65)`       | highlight superior (el brillo Aero)  |
| `shadow`      | `rgba(0,60,120,0.25)`          | sombra fría                          |

### Tipografía

- **UI:** Selawik (open source, look Segoe/Win7). Fallback: Inter.
- **Mono / terminal:** JetBrainsMono Nerd Font (los glyphs de waybar/starship dependen de esto).

### Gloss recipe (el corazón del look — GTK CSS, sirve para waybar/swaync/eww)

```css
/* --- H4UI Aero Glass --- */
background: linear-gradient(to bottom,
  rgba(255,255,255,0.38) 0%,
  rgba(255,255,255,0.10) 45%,
  rgba(160,210,255,0.12) 100%);
border: 1px solid rgba(255,255,255,0.45);
border-radius: 12px;
box-shadow:
  inset 0 1px 0 rgba(255,255,255,0.65),   /* highlight arriba  */
  inset 0 -1px 0 rgba(11,95,165,0.25),    /* linea abajo       */
  0 4px 14px rgba(0,60,120,0.25);         /* sombra fria       */
```

> **Clave:** el *blur real* NO lo hace la CSS (GTK no tiene backdrop-filter). Lo pone **Hyprland**
> detrás del layer. La CSS solo hace el gloss/gradiente/borde. Los dos juntos = vidrio Aero.

### Blur / decoración / animación (valores objetivo — adaptá a tu schema Lua de Hyprland 0.55)

```ini
# decoración
rounding = 12
active_opacity = 0.92
inactive_opacity = 0.86
blur { enabled = true; size = 7; passes = 3; vibrancy = 0.30; new_optimizations = true }

# blur sobre layers (esto es lo que hace que la barra/menús sean vidrio):
layerrule = blur, waybar
layerrule = blur, rofi
layerrule = blur, swaync
layerrule = blur, eww

# animaciones fluidas
bezier = h4uiSmooth, 0.05, 0.9, 0.1, 1.05
bezier = h4uiBounce, 0.34, 1.56, 0.64, 1.0
animation = windows,    1, 5, h4uiBounce, popin 85%
animation = workspaces, 1, 6, h4uiSmooth, slide
animation = fade,       1, 4, h4uiSmooth
animation = border,     1, 8, h4uiSmooth
```

---

## 2. Stack final

**Core / compositor**
- Arch Linux · Hyprland 0.55+ (config Lua modular)
- awww (wallpaper — sucesor de swww, que quedó archivado) · waybar · **rofi-wayland** (el fork; el rofi normal es X11) · alacritty
- zsh + **Starship** (descartamos p10k: TOML legible y comentable, mejor para enseñar)
- **swaync** (notification center con panel glossy; reemplaza a dunst)
- hyprlock + hypridle (lock + idle)

**Login / boot**
- SDDM con tema H4UI · Plymouth (boot splash)

**Theming system-wide** (para que Firefox/nautilus/apps no rompan la estética)
- Tema GTK glossy · Kvantum (Qt) · icon theme + cursor redondeados · Selawik + JetBrainsMono Nerd

**Utilidades con GUI (imprescindibles para un novato)**
- Red: nm-applet · Bluetooth: blueman · Audio: pavucontrol
- File manager: nautilus (o thunar) · USB automount: udiskie
- brightnessctl · playerctl · grim + slurp + swappy (screenshots) · cliphist + wl-clipboard
- **swayosd** (`extra/swayosd`, sin AUR) — burbuja en pantalla al cambiar volumen/brillo

**Widgets / gadgets**
- eww → cheatsheet de atajos (`Super + /`) + gadgets estilo Win7 Sidebar (reloj, clima, recursos)

**Opcional (guiño FA)**
- Sonidos del sistema (arranque/notif) · mpvpaper para wallpaper en video más adelante

---

## 3. Estructura del repo

```
H4UI/
├─ README.md                 # "empezá acá" — onboarding para el novato (cara amable)
├─ INSTALL.md                # instrucciones de instalación
├─ DEVELOPMENT.md            # este plan / notas de dev
├─ install.sh               # entrypoint del instalador interactivo
├─ manifest.<fmt>            # según el formato de ricectl (qué se instala y se enlaza)
│
├─ scripts/
│  ├─ lib/                   # helpers bash (logging, prompts con gum, colores)
│  ├─ 00-preflight.sh        # checks: Arch, internet, GPU AMD, dependencias
│  ├─ 10-packages.sh         # pacman + AUR (bootstrap de paru si falta)
│  ├─ 20-fonts.sh
│  ├─ 30-link-configs.sh     # symlinks vía ricectl
│  ├─ 40-themes.sh           # GTK/Kvantum/icons/cursor/SDDM/Plymouth
│  ├─ 50-services.sh         # enable sddm, etc.
│  ├─ 90-postinstall.sh      # mensaje final lindo
│  └─ h4ui                   # CLI de usuario: reset / update / help / cheatsheet
│
├─ config/                   # todo lo que va a ~/.config
│  ├─ hypr/
│  │  ├─ hyprland.lua        # main, muy comentado
│  │  ├─ modules/            # env.lua, keybinds.lua, animations.lua,
│  │  │                      #   decoration.lua, rules.lua, autostart.lua
│  │  ├─ hyprlock.conf
│  │  └─ hypridle.conf
│  ├─ waybar/                # config.jsonc + style.css
│  ├─ rofi/                  # config.rasi + tema h4ui.rasi
│  ├─ alacritty/             # alacritty.toml
│  ├─ swaync/                # config.json + style.css
│  ├─ eww/                   # eww.yuck + eww.scss + scripts/ (cheatsheet + gadgets)
│  ├─ starship.toml
│  └─ zsh/                   # .zshrc
│
├─ theme/
│  ├─ colors/palette.toml    # ← SOURCE OF TRUTH de color
│  ├─ gtk/                   # gtk-3.0, gtk-4.0, tema glossy
│  ├─ kvantum/
│  ├─ icons/                 # (o referencia al paquete)
│  └─ cursors/
│
├─ sddm/                     # tema H4UI de login
├─ plymouth/                 # tema de boot
├─ wallpapers/               # estático(s) FA
├─ sounds/                   # sonidos del sistema (opcional)
└─ docs/                     # fuente del cheatsheet + guías beginner
```

> **Sobre el linkeo (actualizado):** el ricectl que se menciona acá se perdió y no se reconstruye.
> `home/` espeja `$HOME` (ej. `home/.config/hypr` → `~/.config/hypr`); `install.sh` (Fase 8) lo
> recorre y symlinkea cada cosa, con backup de lo que pisa para que `h4ui reset` pueda revertir.
> Sin manifest propio que mantener.

---

## 4. Keybinds (`Super` = mod)

**`Super` solo no hace nada.** Launcher en `Super + A`, como los tuyos.

| Tecla                          | Acción                          |
|--------------------------------|---------------------------------|
| `mod + Return`                 | Alacritty                       |
| `mod + A`                      | Launcher (rofi drun)            |
| `mod + .`                      | Emoji picker                    |
| `mod + BackSpace`              | Power menu                      |
| `mod + Q`                      | Cerrar ventana                  |
| `mod + F` / `mod + Shift + M`  | Fullscreen / Maximizar          |
| `mod + V`                      | Float + 800×600                 |
| `mod + H/J/K/L`                | Mover foco                      |
| `mod + Shift + H/J/K/L`        | Intercambiar ventanas           |
| `mod + I`                      | Toggle split                    |
| `mod + 1..9`                   | Ir a workspace                  |
| `mod + Shift + 1..9`           | Mover ventana a workspace       |
| `mod + Shift + S`              | Screenshot (región)             |
| `mod + Shift + R`              | Recargar Hyprland               |
| `mod + D`                      | Toggle desktop                  |
| ⭑ `mod + E`                    | File manager (muscle memory Win+E) |
| ⭑ `mod + /`                    | Cheatsheet de atajos (eww)      |
| ⭑ `mod + L`                    | Bloquear pantalla (hyprlock)    |
| ⭑ teclas media                 | Volumen / brillo / play (con OSD)  |

⭑ = agregados pensados para un novato. El resto es tu set tal cual.

---

## 5. Fases de desarrollo (pasá una por una a Claude Code)

Cada fase es un chunk autocontenido. El orden respeta dependencias y prioriza **"tener escritorio
usable rápido → después embellecer → después enseñar → después empaquetar"**.

### Fase 0 — Fundaciones
- Esqueleto del repo (§3).
- `theme/colors/palette.toml` con los tokens de §1.
- `DEVELOPMENT.md` (este plan) dentro del repo.
- **Entregable:** repo vacío pero con estructura y paleta definidas.

### Fase 1 — Base booteable
- Hyprland Lua modular: `env` (AMD), `keybinds` (tabla §4), `animations`, `decoration` (blur/rounding),
  `rules`, `autostart`.
- alacritty.toml + zsh/.zshrc + starship.toml (básicos, con paleta).
- **Entregable:** logueás y tenés un escritorio **usable** con tus atajos. Sin pulir todavía.

### Fase 2 — Barra + launcher + notificaciones
- waybar con módulos GUI: red, bluetooth, audio, batería, reloj, workspaces.
- rofi-wayland (drun en `Super + A`).
- swaync (panel de notificaciones).
- Todo con el **gloss recipe** y `layerrule = blur`.
- **Entregable:** desktop operativo y ya con onda Aero en barra/menús.

### Fase 3 — Estética FA a fondo
- Paleta aplicada en todos los componentes.
- Tuning fino de blur/vibrancy + gloss highlights + curvas de animación.
- swww con wallpaper estático FA. Fuentes (Selawik + JetBrainsMono Nerd). Cursor + icons.
- **Entregable:** "esto es claramente Frutiger Aero".

### Fase 4 — Glass system-wide (GTK/Qt)
- Tema GTK glossy + Kvantum, para que Firefox / nautilus / apps GTK no rompan la estética.
- **Entregable:** abrís Firefox y sigue todo coherente.

### Fase 5 — Login + boot
- SDDM con tema H4UI. hyprlock + hypridle. Plymouth.
- **Entregable:** experiencia coherente **de encender a escritorio**.

### Fase 6 — Widgets / gadgets eww
- Cheatsheet (`Super + /`) que muestra la tabla §4.
- Gadgets estilo Win7 Sidebar: reloj, clima, monitor de recursos.
- **Entregable:** el toque memorable + la ayuda en pantalla para el novato.

### Fase 7 — Capa didáctica
- Comentarios humanos en **todos** los configs (convención del apéndice).
- `README.md` "empezá acá" + guías en `docs/`.
- Sonidos FA opcionales.
- **Entregable:** el rice ya *enseña*, no solo se ve lindo.

### Fase 8 — Instalador + CLI
- `install.sh` interactivo (ricectl mejorado, ver §7).
- CLI `h4ui`: `reset` / `update` / `help` / `cheatsheet`.
- `INSTALL.md`.
- **Entregable:** instalación reproducible y amigable.

### Fase 9 — Repo + deploy real
- Push al repo. Probar el flujo completo (§8) **en una VM Arch limpia** antes de tocar su PC.
- **Entregable:** listo para instalar en su máquina.

---

## 6. Capa didáctica (spec)

Tres piezas:

1. **Comentarios embebidos** en cada config (convención en el apéndice). Cabecera + notas inline.
2. **Cheatsheet en pantalla** (`Super + /`, eww) que refleja la tabla §4 — que nunca tenga que
   memorizar nada.
3. **`README.md` de bienvenida** en el escritorio o primer boot: 8-10 líneas — cómo abrir apps,
   dónde está el cheatsheet, cómo conectarse al wifi, cómo pedir ayuda, y que existe `h4ui reset`.

---

## 7. Instalador interactivo (spec)

Bash + [`gum`](https://github.com/charmbracelet/gum) para prompts lindos (choose/confirm/spin),
apoyado en ricectl para el linkeo.

**Flujo:**
1. **Preflight** — ¿es Arch? ¿hay internet? ¿GPU AMD? Avisa claro si algo falta.
2. **Bootstrap** de un AUR helper (paru) si no está.
3. **Elección** (gum): perfil `completo` / `mínimo` + apps opcionales `[y/N]`.
4. **Paquetes** — pacman + AUR (swww, rofi-wayland, etc.).
5. **Fuentes** — Selawik + JetBrainsMono Nerd.
6. **Link de configs** — vía ricectl (según manifest).
7. **Temas** — GTK/Kvantum/icons/cursor + SDDM + Plymouth.
8. **Servicios** — enable sddm.
9. **Postinstall** — mensaje: *"Reiniciá y apretá `Super + /` para ver todos los atajos."*

**CLI `h4ui`:**
- `h4ui reset [componente]` → revierte config(s) al estado original (red de contención).
- `h4ui update` → pull del repo + re-link.
- `h4ui cheatsheet` → abre la ayuda.
- `h4ui help` → qué es cada comando.

Todo **idempotente** y con `--dry-run`.

---

## 8. Checklist de deploy / testing

Antes de tocar su PC, probar **todo en una VM Arch limpia**:

- [ ] SDDM aparece y loguea → Hyprland arranca sin errores.
- [ ] **Wifi por GUI** (nm-applet) — un novato no puede depender de la terminal para esto.
- [ ] Audio (pavucontrol) y teclas de volumen con OSD.
- [ ] USB se automontea (udiskie).
- [ ] Firefox abre y respeta el tema.
- [ ] `Super + /` abre el cheatsheet.
- [ ] `h4ui reset` funciona.
- [ ] Perf de blur en Vega OK (si lagea, bajá `passes` a 2).

**Deploy real en su PC:** Arch limpio → Firefox → `git clone` → `./install.sh`.

---

## Apéndice — Convención de comentarios (usar en TODOS los configs)

Cabecera al inicio de cada archivo:

```
# ┌─ H4UI ──────────────────────────────────────────────
# │ QUÉ ES:        <una línea, sin tecnicismos>
# │ PODÉS CAMBIAR: <qué se puede tocar sin miedo>
# │ NO TOQUES:     <lo que rompe todo si lo movés>
# └──────────────────────────────────────────────────────
```

Notas inline donde haga falta:

```
gaps_in = 8    # 👉 espacio ENTRE ventanas. Subilo si querés más aire.
```

Reglas del comentario:
- En **español**, tono humano, como explicándole a un amigo.
- Siempre decí *qué pasa si lo cambio*, no solo qué es.
- Marcá con `👉` las líneas que es seguro y divertido tocar.
