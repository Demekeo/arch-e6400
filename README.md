# AwesomeWM para Dell Latitude E6400

Configuración pensada para: Core 2 Duo T9600, 4 GB RAM, Quadro NVS 160M
(nouveau), pantalla 1280x800, Arch Linux.

## Contenido

```
awesome/rc.lua          -> ~/.config/awesome/rc.lua
picom/picom.conf        -> ~/.config/picom/picom.conf
rofi/config.rasi        -> ~/.config/rofi/config.rasi
alacritty/alacritty.toml-> ~/.config/alacritty/alacritty.toml
gtk/settings.ini        -> ~/.config/gtk-3.0/settings.ini y gtk-4.0
gtk/gtkrc-2.0           -> ~/.gtkrc-2.0
xinitrc                 -> ~/.xinitrc
install.sh              -> instala paquetes y copia todo (con backup)
```

## 1. Instalación con archinstall

- Perfil: **Awesome**
- Driver gráfico: **Mesa (open source)**  ← nunca NVIDIA propietario
- Greeter: **None** (el perfil de awesome está pensado para `startx`)
- Audio: **PipeWire**
- Red: **NetworkManager**
- Swap: **zram**
- Microcode: **Intel**
- Bootloader: **GRUB** (el E6400 es BIOS, no UEFI)
- Paquetes extra: `firefox linux-lts mesa-utils zram-generator`

archinstall instala `xorg-server`, `xorg-xinit` y deja
`/etc/X11/xinit/xinitrc` con `exec awesome`.
`xorg-server` ya arrastra `xf86-input-libinput`, así que teclado y
touchpad funcionan sin instalar nada más.

## 2. Primer arranque

Entra por consola (TTY), copia esta carpeta a la laptop y ejecuta:

```bash
cd arch-e6400
bash install.sh
```

El script guarda una copia de las configs anteriores en
`~/.config-backup-<fecha>`, añade una regla udev para que el grupo `video`
pueda controlar el brillo y al final valida la sintaxis con `awesome -k`.
Si añade tu usuario al grupo `video`, cierra sesión y vuelve a entrar
antes de usar las teclas de brillo.

Luego:

```bash
startx
```

Si algo falla, la config de awesome se puede validar sin arrancar:

```bash
awesome -k
```

## 3. Atajos

`Mod4` = tecla Windows.

| Atajo | Acción |
|---|---|
| `Mod4 + Return` | terminal (alacritty) |
| `Mod4 + d` | lanzador rofi |
| `Mod4 + r` | prompt de awesome |
| `Mod4 + j / k` | cambiar foco |
| `Mod4 + Shift + j / k` | mover ventana |
| `Mod4 + 1..9` | ir a tag |
| `Mod4 + Shift + 1..9` | mover ventana a tag |
| `Mod4 + space` | cambiar layout |
| `Mod4 + f` | pantalla completa |
| `Mod4 + Shift + c` | cerrar ventana |
| `Mod4 + Ctrl + r` | recargar awesome |
| `Mod4 + Shift + q` | salir |
| `Print` | captura (flameshot) |
| Teclas volumen / brillo | funcionan |
| Play / Next / Prev | controlan el reproductor (playerctl) |

## 4. Estética

- Tema oscuro Tokyo Night (Storm) en la barra, tags y menús.
- Barra superior de 34 px con: lanzador, 9 tags de colores, lista de
  ventanas, bandeja del sistema, volumen, brillo, batería, RAM, disco,
  wifi, fecha/hora, layout y apagado.
- Cada tag tiene su propio color (rosa, naranja, amarillo, verde, teal,
  cian, azul, violeta y gris): seleccionado en color pleno, ocupado en
  tono tenue y vacío en tono muy tenue.
- Interacción con la barra:
  - **Reloj**: clic abre el calendario; rueda cambia de mes.
  - **Volumen**: clic abre `pavucontrol`; rueda sube/baja 5 %; botón
    central silencia.
  - **Brillo**: rueda del ratón sube/baja 10 %.
  - **Batería**: clic muestra un aviso con nivel y estado de carga.
  - **RAM**: clic muestra el porcentaje de memoria en uso.
  - **Disco**: clic muestra el espacio usado en `/` y su porcentaje.
  - **Wifi**: clic abre `nmtui` para gestionar la red.
  - **Layout** (icono de cuadrícula): clic cambia de layout.
  - **Icono de apagado** (rojo, a la derecha): menú para cerrar sesión,
    reiniciar o apagar.
- Los iconos usan `Symbols Nerd Font` (paquete `ttf-nerd-fonts-symbols`),
  que incluye los glifos de Font Awesome. Si ves cuadrados en vez de
  iconos, comprueba con `fc-match "Symbols Nerd Font"`.
- Bordes de 2 px y gaps de 6 px.
- Esquinas redondeadas y sombras vía picom (sin blur).
- Fondo: `awesome/wallpaper.png` (degradado azul oscuro con un brillo
  teal suave, a juego con la barra). Se instala en
  `~/.config/awesome/wallpaper.png`. Si falta, se usa el fondo de
  `archlinux-wallpaper`.
- Iconos Papirus y tema GTK `Orchis-Dark`: se aplican solos gracias a
  `~/.config/gtk-3.0/settings.ini`, `~/.config/gtk-4.0/settings.ini`
  y `~/.gtkrc-2.0`. Para cambiarlo a mano, usa `lxappearance`.
- Fuente Inter; terminal JetBrains Mono Nerd Font.

## 5. Rendimiento

- picom con `backend = "xrender"` y sin blur: en la G98M el backend `glx`
  congela la pantalla (solo se repinta al mover/cambiar ventanas).
- `vsync = false` y `unredir-if-possible = false` por el mismo motivo.
- Si va lento: `shadow = false` y `corner-radius = 0`.
- Si quieres el máximo rendimiento absoluto, desactiva el compositor:
  `touch ~/.config/picom/off` y `Mod4 + Ctrl + r` (pierdes sombras y
  esquinas redondeadas, ganas fluidez). Para volver: `rm ~/.config/picom/off`.
- No uses `LIBGL_ALWAYS_SOFTWARE`: en un Core 2 Duo es inusable.
- Si cambias `picom.conf`, haz `pkill picom` y luego `Mod4 + Ctrl + r`
  para que awesome lo vuelva a lanzar.

## 6. Problemas típicos

- **Vuelve al rc.lua por defecto**: hay un error de sintaxis. Ejecuta
  `awesome -k` y mira el mensaje; también `~/.xsession-errors`.
- **La pantalla no se repinta** (solo cambia al mover/cambiar ventanas):
  el compositor. Comprueba con `pkill picom`: si se arregla, es picom.
  En esta GPU usa `backend = "xrender"` (el `glx` congela). Si aun así
  falla, desactívalo del todo con `touch ~/.config/picom/off` y
  `Mod4 + Ctrl + r`.
- **picom no arranca**: ejecútalo a mano para ver el error:
  `picom --config ~/.config/picom/picom.conf`. Si el backend `glx` falla
  con nouveau, prueba `backend = "xrender"` (más lento) o comenta el
  autostart de picom.
- **rofi se ve raro o no arranca**: rofi 2.x es el port a Wayland, pero
  mantiene el backend X11 y `rofi -show drun` funciona igual. Prueba
  `rofi -show drun -theme ~/.config/rofi/config.rasi` para ver el error
  real; si el tema falla, arranca sin `-theme` y revisa el `.rasi`.
- **Alacritty no abre**: usa `xterm` (viene instalado) y revisa
  `alacritty --print-events` o el log.
- **El brillo no cambia**: mira `ls /sys/class/backlight/` y prueba
  `brightnessctl set 10%+`. El script crea
  `/etc/udev/rules.d/90-backlight.rules` (el paquete de Arch no trae
  reglas) y te añade al grupo `video`; hace falta volver a entrar.
  Si las teclas Fn no generan evento X (`xev` no muestra
  `XF86MonBrightnessUp`), usa el comando a mano o un atajo propio.
- **Sin notificaciones**: awesome ya trae `naughty` con D-Bus; no instales
  `dunst` a la vez o se pelearán por el bus.

## 7. Extra para el E6400

```bash
sudo pacman -S tlp tlp-rdw
sudo systemctl enable --now tlp
```

Y si puedes: SSD SATA + 8 GB DDR2. Es la mejora más grande que admite
este portátil.

## 8. WiFi del E6400

- **Intel WiFi Link 5100/5300** (`iwlwifi`): funciona directamente con
  NetworkManager (el icono de la barra es `nm-applet`).
- **Broadcom BCM4312** (`lspci -nn | grep -i net`): el driver libre `b43`
  necesita firmware. Si no aparece interfaz, mira
  `dmesg | grep -i -E 'b43|brcm|firmware'`. Las salidas habituales son
  `b43-firmware` o `broadcom-wl-dkms` (ambos en AUR), y conviene revisar
  el interruptor físico de WiFi del portátil.
- Si no tienes Ethernet, puedes instalar usando un adaptador USB-Ethernet
  o compartiendo datos del móvil por USB (tethering), que NetworkManager
  detecta solo.
