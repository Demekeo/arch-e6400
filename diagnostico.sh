#!/usr/bin/env bash
# Recopila informacion para diagnosticar el entorno Awesome del E6400.
# Uso:  bash diagnostico.sh
# Funciona desde la TTY; si X esta corriendo, usa DISPLAY=:0.

out="$HOME/diagnostico.txt"
: > "$out"
exec > >(tee -a "$out") 2>&1

have() { command -v "$1" >/dev/null 2>&1; }

echo "== Fecha =="
date

echo
echo "== Sistema =="
uname -r
grep -E '^(NAME|VERSION_ID)=' /etc/os-release 2>/dev/null

echo
echo "== GPU / driver =="
if have lspci; then
  lspci -nnk 2>/dev/null | grep -A3 -iE 'vga|3d|display'
else
  echo "lspci no instalado"
fi
lsmod 2>/dev/null | grep -E 'nouveau|nvidia' || echo "sin nouveau/nvidia en lsmod"
if [ -f /etc/X11/xorg.conf.d/20-modesetting.conf ]; then
  echo "modesetting: configurado"
  grep -E 'Driver|AccelMethod|DRI' /etc/X11/xorg.conf.d/20-modesetting.conf
else
  echo "modesetting: NO configurado (GLX puede caer en llvmpipe)"
fi
if [ -r /var/log/Xorg.0.log ]; then
  grep -E 'Loading .*(nouveau|modesetting)_drv|AIGLX|GLX: Initialized' \
    /var/log/Xorg.0.log 2>/dev/null | tail -5
fi

echo
echo "== Sesion =="
echo "DISPLAY=${DISPLAY:-<vacio>}"
echo "LIBGL_ALWAYS_SOFTWARE=${LIBGL_ALWAYS_SOFTWARE:-<no>}"
loginctl 2>/dev/null | head -5

echo
echo "== SSH =="
if grep -RhsE '^[[:space:]]*PasswordAuthentication' \
     /etc/ssh/sshd_config /etc/ssh/sshd_config.d/ 2>/dev/null; then
  :
else
  echo "PasswordAuthentication sin definir (por defecto: yes)"
fi
echo "claves autorizadas: $(wc -l < "$HOME/.ssh/authorized_keys" 2>/dev/null || echo 0)"

echo
echo "== WiFi / regulatory =="
pacman -Q wireless-regdb 2>/dev/null || echo "FALTA wireless-regdb"
ls -l /usr/lib/firmware/regulatory.db 2>/dev/null || echo "FALTA /usr/lib/firmware/regulatory.db"
if have iw; then iw reg get 2>&1 | head -6; fi

echo
echo "== Paquetes =="
for p in awesome picom rofi alacritty xorg-server xorg-xinit xterm feh \
         inter-font papirus-icon-theme orchis-theme ttf-jetbrains-mono-nerd \
         ttf-nerd-fonts-symbols noto-fonts-emoji archlinux-wallpaper \
         brightnessctl playerctl network-manager-applet pipewire-pulse \
         mesa-utils wireless-regdb lm_sensors smartmontools; do
  if pacman -Q "$p" >/dev/null 2>&1; then
    echo "OK    $p $(pacman -Q "$p" | awk '{print $2}')"
  else
    echo "FALTA $p"
  fi
done

echo
echo "== Configs =="
for f in "$HOME/.config/awesome/rc.lua" "$HOME/.config/picom/picom.conf" \
         "$HOME/.config/rofi/config.rasi" "$HOME/.config/alacritty/alacritty.toml" \
         "$HOME/.xinitrc" "$HOME/.config/gtk-3.0/settings.ini"; do
  if [ -f "$f" ]; then echo "OK    $f"; else echo "FALTA $f"; fi
done
if [ -f "$HOME/.config/awesome/rc.lua" ]; then
  if grep -q "E6400" "$HOME/.config/awesome/rc.lua"; then
    echo "rc.lua: es el del repo"
  else
    echo "rc.lua: NO es el del repo (¿install.sh no llego a copiar?)"
  fi
fi
echo "Backups de install.sh:"
ls -d "$HOME"/.config-backup-* 2>/dev/null || echo "  ninguno"

echo
echo "== Versiones =="
for c in awesome picom rofi alacritty; do
  if have "$c"; then "$c" --version 2>&1 | head -1; else echo "falta $c"; fi
done

echo
echo "== awesome -k =="
if have awesome; then awesome -k 2>&1; else echo "falta awesome"; fi

echo
echo "== Procesos =="
for p in awesome picom nm-applet; do
  pgrep -a "$p" 2>/dev/null || echo "no corre: $p"
done

echo
echo "== picom (prueba) =="
if ! have picom; then
  echo "falta picom"
elif pgrep -x picom >/dev/null; then
  echo "picom ya esta corriendo (no se lanza otro)"
elif [ -n "${DISPLAY:-}" ]; then
  timeout 6 picom --config "$HOME/.config/picom/picom.conf" --diagnostics 2>&1 | head -50
  echo "exit=$?"
else
  echo "sin DISPLAY. Prueba: DISPLAY=:0 picom --config ~/.config/picom/picom.conf --diagnostics"
fi

echo
echo "== OpenGL =="
if have glxinfo; then
  DISPLAY=${DISPLAY:-:0} glxinfo -B 2>&1 | head -25
else
  echo "glxinfo no instalado (paquete mesa-utils)"
fi

echo
echo "== Flatseal =="
if have flatpak; then
  flatpak override --user --show com.github.tchx84.Flatseal 2>/dev/null ||
    echo "Flatseal no instalado o sin override"
else
  echo "flatpak no instalado"
fi

echo
echo "== Fuentes =="
have fc-match && { fc-match "Inter" 2>&1; fc-match "JetBrainsMono Nerd Font" 2>&1; }
if have fc-list; then
  echo "coincidencias Inter/JetBrains: $(fc-list 2>/dev/null | grep -icE 'Inter|JetBrainsMono Nerd')"
fi

echo
echo "== rofi (prueba 4s) =="
if ! have rofi; then
  echo "falta rofi"
elif [ -n "${DISPLAY:-}" ]; then
  timeout 4 rofi -show drun -theme "$HOME/.config/rofi/config.rasi" 2>&1 | head -25
  echo "exit=$? (124 = abrio bien y se cerro por timeout)"
else
  echo "sin DISPLAY"
fi

echo
echo "== alacritty (prueba 4s) =="
if ! have alacritty; then
  echo "falta alacritty"
elif [ -n "${DISPLAY:-}" ]; then
  timeout 4 alacritty -e true 2>&1 | head -25
  echo "exit=$? (124/0 = abrio bien)"
else
  echo "sin DISPLAY"
fi

echo
echo "== xrandr =="
if have xrandr; then DISPLAY=${DISPLAY:-:0} xrandr --current 2>&1 | head -12; fi

echo
echo "== Xorg (errores/avisos) =="
grep -E '\(EE\)|\(WW\)' /var/log/Xorg.0.log 2>/dev/null | tail -30 || echo "sin /var/log/Xorg.0.log legible"

echo
echo "== ~/.xsession-errors =="
tail -n 60 "$HOME/.xsession-errors" 2>/dev/null || echo "no existe"

echo
echo "== journal (errores) =="
journalctl -b -p err --no-pager 2>/dev/null | tail -25 || echo "sin journal"

echo
echo "== Temperaturas =="
if have sensors; then
  sensors 2>/dev/null | head -30
else
  echo "lm_sensors no instalado"
fi
for z in /sys/class/thermal/thermal_zone*/temp; do
  [ -r "$z" ] || continue
  printf '%s: %s C\n' \
    "$(cat "${z%/temp}/type" 2>/dev/null)" "$(( $(cat "$z") / 1000 ))"
done

echo
echo "== Coredumps =="
if have coredumpctl; then
  coredumpctl --no-pager list 2>/dev/null | tail -8 || true
else
  echo "coredumpctl no disponible"
fi

echo
echo "== FIN =="
echo "Informe guardado en: $out"
