# Instalar H4UI

Guía paso a paso para instalar H4UI en una PC con **Arch Linux**. No hace falta saber
Linux de antemano — vamos despacio.

---

## Antes de empezar

- Tenés que tener Arch Linux ya instalado (con internet andando).
- H4UI se armó y probó en una placa de video **AMD**. En otra placa puede andar igual,
  pero el instalador te va a avisar si no detecta AMD (no te frena, solo te avisa).
- No hace falta que sepas nada de Hyprland, waybar, ni ninguno de estos nombres raros
  todavía. El rice te los va a ir enseñando (por eso tiene comentarios en todos los
  archivos de config).

---

## Paso 1 — Instalar `git` (si no lo tenés)

Abrí una terminal y escribí:

```bash
sudo pacman -S git
```

Te va a pedir tu contraseña (la misma que usás para entrar a la sesión). Es normal, no
se ve nada mientras la escribís — escribila igual y apretá Enter.

## Paso 2 — Clonar el repo

```bash
git clone https://github.com/tu-usuario/H4UI.git
cd H4UI
```

(Cambiá la URL de arriba por la de tu repo real).

## Paso 3 — Correr el instalador

```bash
./install.sh
```

Si te tira un error de permisos, dale primero `chmod +x install.sh` y volvé a
intentar.

### ¿Qué va a pasar?

El instalador hace todo solo, en este orden:

1. **Chequeos previos** — ¿es Arch? ¿hay internet? ¿la placa es AMD? (si algo
   importante falta, te lo dice y para ahí).
2. **Paquetes** — instala todo lo que necesita H4UI (Hyprland, waybar, rofi, etc.) con
   `pacman`, y compila un par de cosas de AUR (te va a pedir tu contraseña de nuevo
   para eso, es normal).
3. **Fuentes** — baja la tipografía Selawik (la que le da el look "Segoe" al rice).
4. **Copiar configs** — copia todos los archivos de configuración a los lugares que
   corresponden (reemplaza directamente lo que haya, para dejar el escritorio
   listo para usar apenas reinicies).
5. **Temas** — chequea que el tema visual (GTK, Kvantum, la pantalla de login) haya
   quedado bien puesto.
6. **Servicios** — activa la pantalla de login (SDDM).
7. **Mensaje final** — con los próximos pasos.

Va a haber momentos donde te pregunte cosas con menús de colores (por ejemplo, si
querés instalar una app opcional). Si no estás seguro, la opción por default suele ser
la más segura.

### ¿Querés ver qué va a hacer, sin instalar nada todavía?

```bash
./install.sh --dry-run
```

Esto te muestra, paso por paso, qué archivos tocaría y qué paquetes instalaría — pero
no cambia absolutamente nada en tu sistema. Sirve para mirar tranquilo antes de la
instalación de verdad.

## Paso 4 — Reiniciar

Cuando el instalador termine, reiniciá la PC:

```bash
reboot
```

En la pantalla de login (ya con la nueva pinta de H4UI), elegí la sesión **Hyprland**
antes de poner tu contraseña — normalmente hay un ícono o un menú abajo a la derecha
o arriba a la derecha para elegir la sesión.

---

## Ya estás adentro — ¿y ahora?

- Apretá **`Super + /`** (la tecla con el logo de Windows/Linux + la barra `/`) para
  ver TODOS los atajos de teclado en pantalla. Es tu chuleta — no hace falta que te
  memorices nada.
- `Super + Enter` abre una terminal.
- `Super + A` abre el buscador de aplicaciones.
- Podés borrar tranquilamente la carpeta `H4UI` que clonaste en el Paso 2 — ya se
  copió todo lo que hacía falta a tu sistema, no depende de que esa carpeta siga ahí
  (salvo que quieras usar `h4ui update` más adelante, ver abajo).

---

## Otros comandos útiles

```bash
h4ui help          # lista todos los comandos
h4ui cheatsheet     # abre/cierra la ayuda de atajos (lo mismo que Super + /)
h4ui update         # trae la última versión del repo (necesita la carpeta H4UI del
                     # Paso 2 — si la borraste, te va a avisar que la vuelvas a clonar)
```

---

## Problemas comunes

- **"No encontré pacman"** — esto no es Arch Linux (o un derivado). H4UI solo anda ahí.
- **"No hay conexión a internet"** — conectate a wifi (o cable) antes de correr el
  instalador. Necesita internet para bajar paquetes.
- **La pantalla de login sigue gris, no cambió** — reiniciá de nuevo; si sigue igual,
  corré `sudo systemctl restart sddm` desde una terminal (por ejemplo con `Ctrl+Alt+F2`
  si estás trabado en una consola de texto).
- **El blur va lento / la PC se calienta** — abrí
  `~/.config/hypr/hyprland.lua`, buscá el bloque `blur` y bajale el número de
  `passes`. Está comentado ahí mismo qué hace cada línea.
- **No sé qué hace tal archivo de config** — abrilo con cualquier editor de texto.
  Todos arrancan con una cajita que explica QUÉ ES, QUÉ PODÉS CAMBIAR sin miedo, y QUÉ
  NO TOCAR.
