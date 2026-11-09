#!/usr/bin/env bash
# Instala los paquetes y copia las configuraciones.
# Uso:  cd arch-e6400 && bash install.sh
set -euo pipefail

cd "$(dirname "$0")"

if [ "$(id -u)" -eq 0 ]; then
  echo "No lo ejecutes como root. Usa tu usuario normal (pedirá sudo)."
  exit 1
fi

echo ">> Instalando paquetes (todo en repos oficiales de Arch)..."
packages=(
  picom rofi feh alacritty thunar
  papirus-icon-theme orchis-theme inter-font
  ttf-jetbrains-mono-nerd otf-font-awesome ttf-nerd-fonts-symbols
  noto-fonts noto-fonts-emoji
  lxappearance qt6ct kvantum
  network-manager-applet
  polkit-gnome
  brightnessctl playerctl xorg-xset xdotool wmctrl arandr
  maim flameshot
  archlinux-wallpaper
  firefox mesa-utils zram-generator
  pipewire pipewire-pulse pipewire-alsa wireplumber
  pavucontrol xdg-user-dirs
  zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions
  eza bat zoxide htop
  flatpak xdg-desktop-portal-gtk
  wireless-regdb lm_sensors smartmontools
  git curl wget python
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

echo ">> Oh My Zsh y Powerlevel10k..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh" || true
fi
if [ ! -d "$HOME/.powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.powerlevel10k" || true
fi

echo ">> Flatpak + Flathub..."
if command -v flatpak >/dev/null 2>&1; then
  sudo flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo || true
  # Remoto de usuario: las apps --user se guardan en /home, no en los 32 GB de /.
  flatpak remote-add --user --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo || true
  # Flatseal (GTK4 + WebKitGTK) no dibuja la ventana en esta GPU. Forzamos
  # render por software y desactivamos compositing/DMABUF solo para esa app.
  if flatpak list --app --columns=application 2>/dev/null |
     grep -qx com.github.tchx84.Flatseal; then
    flatpak override --user \
      --env=GSK_RENDERER=cairo \
      --env=WEBKIT_DISABLE_COMPOSITING_MODE=1 \
      --env=WEBKIT_DISABLE_DMABUF_RENDERER=1 \
      com.github.tchx84.Flatseal || true
  fi
fi

echo ">> Driver X para la GPU NV98 (modesetting)..."
# nouveau funciona por KMS/GBM, pero el driver X "nouveau" hace que GLX
# caiga en llvmpipe. modesetting usa DRI3 + glamor y deja GLX acelerado.
# No se activa por defecto para no arriesgar una pantalla negra: es opt-in.
if [ -f xorg/20-modesetting.conf ]; then
  if [ "${ARCH_E6400_MODESETTING:-0}" = "1" ]; then
    sudo install -Dm644 xorg/20-modesetting.conf \
      /etc/X11/xorg.conf.d/20-modesetting.conf
    echo "   Instalado. Se aplicará al reiniciar X (cierra sesión o reinicia)."
  else
    echo "   No se activa por defecto. Para instalarlo:"
    echo "     sudo install -Dm644 xorg/20-modesetting.conf \\"
    echo "       /etc/X11/xorg.conf.d/20-modesetting.conf"
    echo "   O vuelve a ejecutar: ARCH_E6400_MODESETTING=1 bash install.sh"
  fi
fi

echo ">> neofetch..."
if [ -f neofetch/neofetch ]; then
  sudo install -Dm755 neofetch/neofetch /usr/local/bin/neofetch
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

# Copia el archivo solo si no existe. Se usa para configuraciones que el
# usuario personaliza (por ejemplo, el prompt de p10k) y no deben perderse
# al actualizar el repositorio.
install_file_keep() {
  local src="$1" dst="$2"
  if [ -f "$dst" ]; then
    echo "   Conservando $dst (configuracion existente)"
    return 0
  fi
  install_file "$src" "$dst"
}

install_file awesome/rc.lua            "$HOME/.config/awesome/rc.lua"
install_file awesome/wallpaper.png     "$HOME/.config/awesome/wallpaper.png"
install_file picom/picom.conf          "$HOME/.config/picom/picom.conf"
install_file rofi/config.rasi          "$HOME/.config/rofi/config.rasi"
install_file alacritty/alacritty.toml  "$HOME/.config/alacritty/alacritty.toml"
install_file gtk/settings.ini          "$HOME/.config/gtk-3.0/settings.ini"
install_file gtk/settings.ini          "$HOME/.config/gtk-4.0/settings.ini"
install_file gtk/gtkrc-2.0             "$HOME/.gtkrc-2.0"
install_file xinitrc                   "$HOME/.xinitrc"
install_file zsh/zshrc                 "$HOME/.zshrc"
install_file_keep zsh/p10k.zsh         "$HOME/.p10k.zsh"
install_file neofetch/config.conf      "$HOME/.config/neofetch/config.conf"
install_file neofetch/ascii.txt        "$HOME/.config/neofetch/ascii.txt"
install_file wallpaper/wallpaper-apply "$HOME/.local/bin/wallpaper-apply"
install_file wallpaper/wallpaper-menu  "$HOME/.local/bin/wallpaper-menu"
install_file bin/opencode-web          "$HOME/.local/bin/opencode-web"
install_file bin/opencode-term         "$HOME/.local/bin/opencode-term"
install_file applications/opencode-web.desktop "$HOME/.local/share/applications/opencode-web.desktop"
install_file applications/opencode-term.desktop "$HOME/.local/share/applications/opencode-term.desktop"
sed -i "s|@HOME@|$HOME|g" "$HOME/.local/share/applications/opencode-web.desktop"
sed -i "s|@HOME@|$HOME|g" "$HOME/.local/share/applications/opencode-term.desktop"
chmod +x "$HOME/.xinitrc" "$HOME/.local/bin/wallpaper-apply" \
  "$HOME/.local/bin/wallpaper-menu" "$HOME/.local/bin/opencode-web" \
  "$HOME/.local/bin/opencode-term"

echo ">> Copiando fondos de pantalla..."
mkdir -p "$HOME/.config/awesome/wallpapers"
cp -f wallpapers/*.png "$HOME/.config/awesome/wallpapers/"
cp -f awesome/wallpaper.png "$HOME/.config/awesome/wallpapers/macchiato-default.png"
if [ ! -f "$HOME/.config/awesome/wallpaper.conf" ]; then
  printf '%s\n' "$HOME/.config/awesome/wallpaper.png" \
    > "$HOME/.config/awesome/wallpaper.conf"
fi

echo ">> Shell por defecto: zsh..."
if command -v zsh >/dev/null 2>&1 && [ "${SHELL:-}" != "/usr/bin/zsh" ]; then
  sudo chsh -s /usr/bin/zsh "$USER" || true
fi

echo ">> zram (si no estaba configurado)..."
if [ ! -f /etc/systemd/zram-generator.conf ]; then
  printf '[zram0]\nzram-size = min(ram / 2, 4096)\ncompression-algorithm = zstd\n' \
    | sudo tee /etc/systemd/zram-generator.conf >/dev/null
  sudo systemctl daemon-reload
fi
sudo systemctl start systemd-zram-setup@zram0.service 2>/dev/null || true

xdg-user-dirs-update 2>/dev/null || true

echo ">> Aplicando el fondo de pantalla..."
if [ -n "${DISPLAY:-}" ]; then
  "$HOME/.local/bin/wallpaper-apply" 2>/dev/null || true
fi

echo ">> Reiniciando picom con la config nueva..."
pkill -x picom 2>/dev/null || true
sleep 1
if [ -f "$HOME/.config/picom/off" ]; then
  echo "   (~/.config/picom/off existe: no se lanza picom)"
elif [ -n "${DISPLAY:-}" ]; then
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
echo "1) Cierra sesión y vuelve a entrar (para el grupo video y zsh)."
echo "2) Arranca con:  startx"
echo "3) Si quieres cambiar el prompt:  p10k configure"
