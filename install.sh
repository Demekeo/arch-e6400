#!/usr/bin/env bash
# Instala los paquetes y copia las configuraciones de awesome.
# Uso:  cd arch-e6400 && bash install.sh
set -euo pipefail

cd "$(dirname "$0")"

if [ "$(id -u)" -eq 0 ]; then
  echo "No lo ejecutes como root. Usa tu usuario normal (pedirá sudo)."
  exit 1
fi

echo ">> Instalando paquetes (todo en repos oficiales de Arch)..."
packages=(
  picom rofi feh alacritty
  papirus-icon-theme orchis-theme inter-font
  ttf-jetbrains-mono-nerd otf-font-awesome ttf-nerd-fonts-symbols
  noto-fonts noto-fonts-emoji
  lxappearance qt6ct kvantum
  network-manager-applet
  brightnessctl playerctl xorg-xset xdotool wmctrl arandr
  maim flameshot
  archlinux-wallpaper
  firefox mesa-utils zram-generator
  pipewire pipewire-pulse pipewire-alsa wireplumber
  pavucontrol xdg-user-dirs
)

# Si un paquete no existe o falla la red, NO abortamos: seguimos copiando
# las configuraciones para que el escritorio quede usable.
failed=()
if ! sudo pacman -S --needed --noconfirm "${packages[@]}"; then
  echo ">> La instalación conjunta falló. Probando paquete por paquete..."
  for p in "${packages[@]}"; do
    if ! sudo pacman -S --needed --noconfirm "$p"; then
      failed+=("$p")
    fi
  done
fi

if [ ${#failed[@]} -gt 0 ]; then
  echo ">> OJO: no se pudieron instalar: ${failed[*]}"
  echo "   El escritorio se configura igual; instala esos paquetes luego."
fi

echo ">> Permisos para el brillo..."
sudo usermod -aG video "$USER" || true
# El paquete brightnessctl de Arch no trae reglas udev: sin esto, el grupo
# video no puede escribir en /sys/class/backlight/*/brightness.
sudo tee /etc/udev/rules.d/90-backlight.rules >/dev/null <<'EOF'
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/usr/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", RUN+="/usr/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=backlight --action=add

echo ">> Copiando configuraciones (con copia de seguridad de lo anterior)..."
backup="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"

install_file() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ]; then
    cp -a "$dst" "$backup/$(echo "$dst" | tr '/' '_')"
  fi
  cp "$src" "$dst"
}

install_file awesome/rc.lua            "$HOME/.config/awesome/rc.lua"
install_file picom/picom.conf          "$HOME/.config/picom/picom.conf"
install_file rofi/config.rasi          "$HOME/.config/rofi/config.rasi"
install_file alacritty/alacritty.toml  "$HOME/.config/alacritty/alacritty.toml"
install_file gtk/settings.ini          "$HOME/.config/gtk-3.0/settings.ini"
install_file gtk/settings.ini          "$HOME/.config/gtk-4.0/settings.ini"
install_file gtk/gtkrc-2.0             "$HOME/.gtkrc-2.0"
install_file xinitrc                   "$HOME/.xinitrc"
chmod +x "$HOME/.xinitrc"

echo ">> zram (si no estaba configurado)..."
if [ ! -f /etc/systemd/zram-generator.conf ]; then
  printf '[zram0]\nzram-size = min(ram / 2, 4096)\ncompression-algorithm = zstd\n' \
    | sudo tee /etc/systemd/zram-generator.conf >/dev/null
  sudo systemctl daemon-reload
fi
sudo systemctl start systemd-zram-setup@zram0.service 2>/dev/null || true

xdg-user-dirs-update 2>/dev/null || true

echo ">> Reiniciando picom con la config nueva..."
pkill -x picom 2>/dev/null || true
sleep 1
if [ -n "${DISPLAY:-}" ]; then
  nohup picom --config "$HOME/.config/picom/picom.conf" >/dev/null 2>&1 &
else
  echo "   (sin DISPLAY: se lanzara al entrar con startx)"
fi

echo ">> Comprobando la sintaxis de la config de awesome..."
if awesome -k; then
  echo "   Config OK."
else
  echo "   OJO: awesome -k ha fallado. Revisa el mensaje de arriba."
fi

echo
echo "Listo. Copia de seguridad de lo anterior en: $backup"
echo "1) Cierra sesión y vuelve a entrar (para el grupo video)."
echo "2) Arranca con:  startx"
