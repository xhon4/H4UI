-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  H4UI · hyprland.lua                                                ║
-- ║  Config principal de Hyprland (0.55+, formato Lua).                 ║
-- ║  Va en:  ~/.config/hypr/hyprland.lua                                ║
-- ║                                                                    ║
-- ║  Este archivo se lee de arriba a abajo. Cada sección tiene una      ║
-- ║  cajita que te dice QUÉ ES, QUÉ PODÉS CAMBIAR y QUÉ NO TOCAR.       ║
-- ║  Las líneas con 👉 son las divertidas de tocar. Dale nomás.         ║
-- ║  Si algo se rompe, corré:  h4ui reset                              ║
-- ╚══════════════════════════════════════════════════════════════════╝


-- ┌─ ENTORNO (variables de entorno) ────────────────────────────────────
-- │ QUÉ ES:        cositas que le avisan a los programas "estás en Wayland".
-- │ PODÉS CAMBIAR: el tamaño del cursor (XCURSOR_SIZE).
-- │ NO TOQUES:     el resto, salvo que sepas lo que hacés.
-- │ NOTA AMD:      tu placa (Vega) NO necesita nada especial. El quilombo
-- │                de variables es cosa de NVIDIA; nosotros zafamos.
-- └─────────────────────────────────────────────────────────────────────
hl.env("XCURSOR_SIZE", "24")            -- 👉 tamaño del puntero del mouse
hl.env("HYPRCURSOR_SIZE", "24")         -- 👉 idem, para apps nuevas
hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")     -- 👉 tema del cursor (tiene que estar instalado)
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")  -- idem, para apps que usan el protocolo nuevo
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct:qt6ct") -- 👉 lista con ":" — cada Qt (5 o 6) usa el que le toca
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("MOZ_ENABLE_WAYLAND", "1")       -- Firefox nativo en Wayland (más nítido)


-- ┌─ MONITORES ─────────────────────────────────────────────────────────
-- │ QUÉ ES:        cómo se configuran las pantallas.
-- │ PODÉS CAMBIAR: si querés forzar resolución/refresh, ver el ejemplo.
-- │ NO TOQUES:     dejá el "auto" si andás bien; detecta todo solo.
-- └─────────────────────────────────────────────────────────────────────
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.0 })
-- Ejemplo si algún día querés forzar una pantalla concreta:
-- hl.monitor({ output = "DP-1", mode = "1920x1080@144", position = "0x0", scale = 1.0 })


-- ┌─ LOOK & FEEL (lo que le da la onda Frutiger Aero) ───────────────────
-- │ QUÉ ES:        gaps, bordes, redondeo, transparencias y el BLUR de vidrio.
-- │ PODÉS CAMBIAR: casi todo lo marcado con 👉. Jugá con los números.
-- │ NO TOQUES:     los nombres de las claves (gaps_in, blur, etc.).
-- └─────────────────────────────────────────────────────────────────────
hl.config({
  general = {
    gaps_in     = 6,   -- 👉 espacio ENTRE ventanas
    gaps_out    = 12,  -- 👉 espacio contra el borde de la pantalla
    border_size = 2,   -- 👉 grosor del borde de la ventana activa
    -- En la config Lua el color va en una sub-tabla "col".
    -- El degradé (aqua → verde-lima, bien FA) se arma con { colors = {...}, angle = N }.
    -- (Un color solo, sin degradé, va como string común — ver inactive_border.)
    col = {
      active_border   = { colors = { "rgba(29abe2ee)", "rgba(8cc63fee)" }, angle = 45 },
      inactive_border = "rgba(0b5fa555)", -- 👉 borde de las ventanas inactivas
    },
    layout = "dwindle",
  },

  decoration = {
    rounding         = 12,   -- 👉 qué tan redondeadas las esquinas
    active_opacity   = 1, -- 👉 transparencia de la ventana enfocada (1 = opaca)
    inactive_opacity = 1, -- 👉 transparencia de las de atrás

    -- El "vidrio Aero": esto es lo que hace el efecto de fondo borroso.
    
    blur = {
      enabled           = true,
      size              = 0,    -- 👉 qué tan fuerte el desenfoque
      passes            = 0,    -- 👉 calidad del blur. Si LAGEA, bajalo a 2.
      vibrancy          = 0.30, -- 👉 satura los colores detrás del vidrio (muy FA)
      new_optimizations = true,
    },

    -- Sombra fría, suave, tipo agua.
    shadow = {
      enabled      = true,
      range        = 20,
      render_power = 3,
      color        = "rgba(0b5fa544)",
    },
  },

  input = {
    kb_layout    = "latam", -- 👉 teclado. "latam" = español latino. Cambialo a "us" si preferís.
    follow_mouse = 1,       -- el foco sigue al mouse
    touchpad     = { natural_scroll = true, tap_to_click = true },
  },

  dwindle = {
    preserve_split = true, -- recuerda cómo dividiste las ventanas
    -- (pseudotile se removió en 0.55; ahora es por-ventana con la regla "pseudo")
  },

  misc = {
    disable_hyprland_logo   = true, -- sin el logo de fondo por defecto
    force_default_wallpaper = 0,
    -- (vfr se movió a debug: en 0.55 y ya viene activado por defecto)
  },
})


-- ┌─ ANIMACIONES (que todo se sienta fluido y con "rebote") ─────────────
-- │ QUÉ ES:        las curvas y velocidades de las animaciones.
-- │ PODÉS CAMBIAR: los "speed" (más chico = más lento) y las curvas 👉.
-- │ NO TOQUES:     los nombres de las curvas si los usás abajo.
-- └─────────────────────────────────────────────────────────────────────
-- Una curva suave (ease-out) y una con rebotecito (bounce), bien Aero.
hl.curve("h4uiSmooth", { type = "bezier", points = { { 0.05, 0.90 }, { 0.10, 1.05 } } })
hl.curve("h4uiBounce", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1.00 } } })

hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "h4uiBounce", style = "popin 85%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "h4uiSmooth", style = "slide" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "h4uiSmooth" })
hl.animation({ leaf = "border",     enabled = true, speed = 8, bezier = "h4uiSmooth" })
hl.animation({ leaf = "layers",     enabled = true, speed = 5, bezier = "h4uiSmooth", style = "fade" })


-- ┌─ BLUR EN LA BARRA Y LOS MENÚS (clave del look FA) ───────────────────
-- │ QUÉ ES:        le decimos a Hyprland "poné vidrio detrás de estas cosas".
-- │ PODÉS CAMBIAR: nada, salvo agregar más apps a la lista.
-- │ NO TOQUES:     los "namespace" (son los nombres internos de cada app).
-- └─────────────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "waybar" },                   blur = true })
hl.layer_rule({ match = { namespace = "rofi" },                     blur = true })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true })
hl.layer_rule({ match = { namespace = "swaync-control-center" },    blur = true })
hl.layer_rule({ match = { namespace = "eww" },                      blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ match = { namespace = "swayosd" },                  blur = true })


-- ┌─ REGLAS DE VENTANAS ─────────────────────────────────────────────────
-- │ QUÉ ES:        que ciertas ventanitas (volumen, wifi, etc.) floten
-- │                centradas en vez de partir la pantalla.
-- │ PODÉS CAMBIAR: agregá más "class" a la lista si alguna app molesta.
-- │ NO TOQUES:     la estructura del match.
-- └─────────────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = "pavucontrol" },           float = true, center = true })
hl.window_rule({ match = { class = "blueman-manager" },       float = true, center = true })
hl.window_rule({ match = { class = "nm-connection-editor" },  float = true, center = true })
hl.window_rule({ match = { title = "Open File" },             float = true, center = true })


-- ┌─ ATAJOS DE TECLADO ─────────────────────────────────────────────────
-- │ QUÉ ES:        todas las combinaciones. "mod" es la tecla SUPER (⊞).
-- │ PODÉS CAMBIAR: lo que quieras. Copiá una línea y cambiá la tecla/acción.
-- │ NO TOQUES:     nada te va a romper el sistema acá, tranqui. Experimentá.
-- │ AYUDA:         apretá  mod + /  para ver esta lista en pantalla.
-- └─────────────────────────────────────────────────────────────────────
local mod = "SUPER"   -- 👉 si algún día querés que el "menú" sea ALT, cambiá esto

-- Apps
hl.bind(mod .. "+Return",    hl.dsp.exec_cmd("alacritty"),                    { desc = "Abrir terminal" })
hl.bind(mod .. "+A",         hl.dsp.exec_cmd("rofi -show drun"),              { desc = "Abrir el menú de apps (Inicio)" })
hl.bind(mod .. "+E",         hl.dsp.exec_cmd("nautilus"),                     { desc = "Abrir el explorador de archivos" })
hl.bind(mod .. "+period",    hl.dsp.exec_cmd("bemoji"),                       { desc = "Selector de emojis" })  -- 'period' = la tecla .
hl.bind(mod .. "+L",         hl.dsp.exec_cmd("hyprlock"),                     { desc = "Bloquear la pantalla" })

-- Menú de apagado/reinicio (se arma en la fase de rofi; por ahora apunta al script)
hl.bind(mod .. " + BackSpace", hl.dsp.exec_cmd("~/.config/hypr/scripts/power_menu.sh"), { desc = "Menú de apagado" })

-- Cheatsheet de atajos (eww, Fase 6 — el daemon arranca más abajo en autostart)
hl.bind(mod .. "+slash",     hl.dsp.exec_cmd("~/.config/hypr/scripts/cheatsheet.sh"), { desc = "Ver todos los atajos" }) -- 'slash' = la tecla /

-- Manejo de ventanas
hl.bind(mod .. "+Q",         hl.dsp.window.close(),                                          { desc = "Cerrar ventana" })
hl.bind(mod .. "+F",         hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { desc = "Pantalla completa" })
hl.bind(mod .. "+SHIFT+M",   hl.dsp.window.fullscreen({ mode = "maximized",  action = "toggle" }), { desc = "Maximizar" })
hl.bind(mod .. "+I",         hl.dsp.layout("togglesplit"),                                  { desc = "Cambiar orientación del split" }) -- (dwindle)

-- Flotar + centrar. (El tamaño exacto 800x600 lo sumamos cuando quieras.)
hl.bind(mod .. " + V", function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    hl.dispatch(hl.dsp.window.resize({ x = 800, y = 600 }))
end)

-- Mover el FOCO entre ventanas (estilo vim: H◄ J▼ K▲ L►)
hl.bind(mod .. "+H", hl.dsp.focus({ direction = "left"  }), { desc = "Foco a la izquierda" })
hl.bind(mod .. "+J", hl.dsp.focus({ direction = "down"  }), { desc = "Foco abajo" })
hl.bind(mod .. "+K", hl.dsp.focus({ direction = "up"    }), { desc = "Foco arriba" })
hl.bind(mod .. "+L", hl.dsp.focus({ direction = "right" }), { desc = "Foco a la derecha" })

-- INTERCAMBIAR ventanas de lugar (mod + SHIFT + dirección)
hl.bind(mod .. "+SHIFT+H", hl.dsp.window.swap({ direction = "left"  }), { desc = "Mover ventana a la izquierda" })
hl.bind(mod .. "+SHIFT+J", hl.dsp.window.swap({ direction = "down"  }), { desc = "Mover ventana abajo" })
hl.bind(mod .. "+SHIFT+K", hl.dsp.window.swap({ direction = "up"    }), { desc = "Mover ventana arriba" })
hl.bind(mod .. "+SHIFT+L", hl.dsp.window.swap({ direction = "right" }), { desc = "Mover ventana a la derecha" })

-- Escritorios (workspaces) 1 al 9.
-- Esto es un "for": en vez de escribir 18 líneas a mano, las genera solas. 👀
for i = 1, 9 do
  local n = tostring(i)
  hl.bind(mod .. "+" .. n,          hl.dsp.focus({ workspace = n }),       { desc = "Ir al escritorio " .. n })
  hl.bind(mod .. "+SHIFT+" .. n,    hl.dsp.window.move({ workspace = n }), { desc = "Mandar ventana al escritorio " .. n })
end

-- Captura de pantalla (seleccionás una región y se abre el editor)
hl.bind(mod .. "+SHIFT+S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | swappy -f -'), { desc = "Captura de región" })

-- Recargar Hyprland (aplica cambios sin reiniciar)
hl.bind(mod .. "+SHIFT+R", hl.dsp.exec_cmd("hyprctl reload"), { desc = "Recargar la config" })

-- Teclas de volumen / brillo / música (las del teclado, con repetición).
-- 'locked = true' = funcionan incluso con la pantalla bloqueada.
-- 👉 Volumen y brillo pasan por swayosd-client: además de cambiar el valor,
--    hace aparecer la burbuja en pantalla (ver swayosd/style.css). Si algún
--    día sacás swayosd, estas dos volverían a ser wpctl/brightnessctl directo.
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume raise"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("swayosd-client --output-volume lower"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- Mouse: mod + arrastrar para mover / redimensionar ventanas flotantes
hl.bind(mod .. "+mouse:272", hl.dsp.window.drag(),                        { desc = "Arrastrar ventana con el mouse" })
hl.bind(mod .. "+mouse:273", hl.dsp.window.resize({ keep_aspect_ratio = false }), { desc = "Redimensionar con el mouse" })


-- ┌─ MOSTRAR ESCRITORIO (mod + D) ──────────────────────────────────────
-- │ QUÉ ES:        oculta/mostra todas las ventanas usando un escritorio
-- │                "especial" (como un cajón). Apretás de nuevo y vuelven.
-- │ NOTA:          esta es una versión simple y funcional. Si querés portar
-- │                tu "minimizar todo" real, reemplazá el cuerpo de abajo.
-- └─────────────────────────────────────────────────────────────────────
hl.bind(mod .. "+D", hl.dsp.workspace.toggle_special("desktop"), { desc = "Mostrar/ocultar escritorio" })


-- ┌─ ARRANQUE AUTOMÁTICO ────────────────────────────────────────────────
-- │ QUÉ ES:        programas que se abren solos al iniciar sesión.
-- │ PODÉS CAMBIAR: agregá o sacá líneas (ej. una app que quieras al inicio).
-- │ NO TOQUES:     el envoltorio hl.on("hyprland.start", ...). Es lo que
-- │                hace que esto corra UNA sola vez y no cada vez que guardás.
-- └─────────────────────────────────────────────────────────────────────
hl.on("hyprland.start", function()
  hl.exec_cmd("hyprpolkitagent")                     -- pide permisos por ventanita (necesario para novatos)
  hl.exec_cmd("eww daemon")                          -- 👉 motor de widgets de eww (necesario para el cheatsheet de Super + /)
  hl.exec_cmd("waybar")                              -- la barra
  hl.exec_cmd("swaync")                              -- centro de notificaciones
  hl.exec_cmd("swayosd-server -s ~/.config/swayosd/style.css") -- burbuja de volumen/brillo
  hl.exec_cmd("nm-applet --indicator")               -- iconito de wifi/red
  hl.exec_cmd("blueman-applet")                      -- iconito de bluetooth
  hl.exec_cmd("udiskie")                             -- montar pendrives automáticamente
  hl.exec_cmd("hypridle")                            -- apagar pantalla tras inactividad
  hl.exec_cmd("wl-paste --watch cliphist store")     -- historial de copiar/pegar

  -- Wallpaper: primero prende el daemon, espera un toque, después lo pone.
  hl.exec_cmd("awww-daemon")
  hl.exec_cmd("sleep 1 && awww img ~/.config/hypr/wallpaper.png") -- 👉 cambiá la ruta a tu fondo FA
end)
