#!/bin/sh
# ~/.xinitrc

# Los lanzadores .desktop y rofi buscan los scripts por nombre.
export PATH="$HOME/.local/bin:$PATH"

# Color de respaldo por si feh falla (nunca dejar el fondo en negro).
xsetroot -solid "#0b0d18" 2>/dev/null || true

# Panel TN de 6 bits: subir la saturacion del motor de color de nouveau.
# Escala 0-200: 150 = neutro (1.0x), 175 = 1.5x, 200 = 2.0x.
xrandr --output LVDS-1 --set "color vibrance" 175 2>/dev/null || true
xrandr --output LVDS-1 --set "vibrant hue" 90 2>/dev/null || true

# Fondo gestionado por ~/.local/bin/wallpaper-menu (feh + wallpaper.conf).
"$HOME/.local/bin/wallpaper-apply" 2>/dev/null || true

exec awesome
