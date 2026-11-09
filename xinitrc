#!/bin/sh
# ~/.xinitrc

# Los lanzadores .desktop y rofi buscan los scripts por nombre.
export PATH="$HOME/.local/bin:$PATH"

# Color de respaldo por si feh falla (nunca dejar el fondo en negro).
xsetroot -solid "#0b0d18" 2>/dev/null || true

# Fondo gestionado por ~/.local/bin/wallpaper-menu (feh + wallpaper.conf).
"$HOME/.local/bin/wallpaper-apply" 2>/dev/null || true

exec awesome
