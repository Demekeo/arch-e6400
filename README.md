# AwesomeWM para Dell Latitude E6400

Configuración pensada para: Core 2 Duo T9600, 4 GB RAM, Quadro NVS 160M
(nouveau), pantalla 1280x800, Arch Linux.

## Contenido

```
awesome/rc.lua          -> ~/.config/awesome/rc.lua
awesome/wallpaper.png   -> fondo por defecto
wallpapers/*.png        -> ~/.config/awesome/wallpapers/ (gestor de fondos)
wallpaper/wallpaper-menu-> ~/.local/bin/wallpaper-menu (rofi + feh)
wallpaper/wallpaper-apply-> ~/.local/bin/wallpaper-apply
bin/opencode-web        -> ~/.local/bin/opencode-web (abre OpenCode remoto)
bin/opencode-term       -> ~/.local/bin/opencode-term (TUI remota en Alacritty)
applications/opencode-web.desktop -> ~/.local/share/applications/
applications/opencode-term.desktop -> ~/.local/share/applications/
picom/picom.conf        -> ~/.config/picom/picom.conf
rofi/config.rasi        -> ~/.config/rofi/config.rasi
alacritty/alacritty.toml-> ~/.config/alacritty/alacritty.toml
zsh/zshrc              -> ~/.zshrc (Oh My Zsh)
zsh/p10k.zsh           -> ~/.p10k.zsh (Powerlevel10k)
neofetch/neofetch       -> /usr/local/bin/neofetch
neofetch/config.conf    -> ~/.config/neofetch/config.conf
neofetch/ascii.txt      -> ~/.config/neofetch/ascii.txt
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
pueda controlar el brillo, instala **Oh My Zsh + Powerlevel10k** (clona
ambos de GitHub), pone **zsh** como shell por defecto e instala
**neofetch**, **flatpak** con Flathub y el gestor de fondos.

Si ya tienes `~/.p10k.zsh`, **no se sobrescribe**: se conserva tu
configuración del prompt. Para volver a la versión del repo:
`cp zsh/p10k.zsh ~/.p10k.zsh`.
Si añade tu usuario al grupo `video`, cierra sesión y vuelve a entrar
antes de usar las teclas de brillo (también es necesario para que zsh
sea tu shell).

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
| `Mod4 + e` | archivos (Thunar) |
| `Mod4 + b` | Firefox |
| `Mod4 + \`` | cambiar de ventana (rofi) |
| `Mod4 + r` | prompt de awesome |
| `Mod4 + j / k` | cambiar foco |
| `Mod4 + Shift + j / k` | mover ventana |
| `Mod4 + Shift + Left / Right` | mover ventana al tag anterior/siguiente |
| `Mod4 + 1..9` | ir a tag |
| `Mod4 + Shift + 1..9` | mover ventana a tag |
| `Mod4 + space` | cambiar layout |
| `Mod4 + f` | pantalla completa |
| `Mod4 + Shift + c` | cerrar ventana |
| `Mod4 + Shift + w` | gestor de fondos |
| `Mod4 + Shift + p` | menú de energía |
| `Mod4 + Shift + s` / `Print` | captura de pantalla (flameshot) |
| `Shift + Print` | captura completa al portapapeles |
| `Mod4 + Ctrl + b` | mostrar/ocultar la barra |
| `Mod4 + Ctrl + r` | recargar awesome |
| `Mod4 + Shift + q` | salir |
| Teclas volumen / brillo | funcionan |
| `XF86AudioMicMute` | silenciar micrófono |
| Play / Next / Prev | controlan el reproductor (playerctl) |

## 4. Estética y barra

- Tema **Catppuccin Macchiato** (`#24273a`) en la barra, tags, menús y
  notificaciones.
- Barra superior de 35 px **translúcida** (`opacity = 0.90`): picom
  respeta la transparencia. Si desactivas picom, la barra se ve opaca.
- Distribución de la barra:
  - **Izquierda**: 8 lanzadores (Alacritty, Arch, editor, Thunar,
    Firefox, rofi, Flameshot y fondos), separador, 9 tags de colores,
    iconos de las ventanas abiertas y el prompt de awesome.
  - **Centro**: vacío, como en la referencia.
  - **Derecha**: volumen, brillo, batería, RAM, disco, wifi, fecha/hora,
    bandeja del sistema y layout.
- Los botones de la barra se **resaltan al pasar el ratón** y muestran un
  tooltip con lo que hace cada clic.
- Lanzadores: clic izquierdo abre la aplicación; **clic derecho en el
  logo de Arch** abre el menú de energía (cerrar sesión, reiniciar,
  apagar).
- Cada tag tiene su propio color (rojo, melocotón, amarillo, verde,
  teal, celeste, azul, malva y lavanda): seleccionado en color pleno,
  ocupado en tono tenue y vacío en tono muy tenue.
- Los iconos de las ventanas en la barra muestran solo el icono de la
  aplicación (sin texto), como en la referencia.
- Interacción con la barra:
  - **Reloj**: clic abre el calendario; rueda cambia de mes.
  - **Volumen**: clic abre `pavucontrol`; botón central o derecho
    silencia; rueda sube/baja 5 %.
  - **Brillo**: rueda del ratón sube/baja 10 %; clic muestra el nivel.
  - **Batería**: clic muestra un aviso con nivel y estado de carga.
  - **RAM**: clic muestra el porcentaje en uso; clic derecho abre `htop`.
  - **Disco**: muestra el espacio libre de `/home`; clic muestra el uso
    de `/` y `/home`; clic derecho abre Thunar en tu carpeta personal.
  - **Wifi**: clic abre `nmtui`; clic derecho muestra el nombre de la red.
  - **Layout** (icono de cuadrícula): clic cambia de layout.
  - **Iconos de ventanas**: clic enfoca o minimiza; clic central cierra;
    clic derecho abre la lista de ventanas; rueda cambia el foco.
- Los iconos usan `Symbols Nerd Font` (paquete `ttf-nerd-fonts-symbols`),
  que incluye los glifos de Font Awesome. Si ves cuadrados en vez de
  iconos, comprueba con `fc-match "Symbols Nerd Font"`.
- Bordes de 2 px, gaps de 8 px y layout inicial `tile.left` (ventana
  principal a la derecha), igual que en la captura de referencia.
- Esquinas redondeadas y sombras vía picom (sin blur).
- Iconos Papirus y tema GTK `Orchis-Dark`: se aplican solos gracias a
  `~/.config/gtk-3.0/settings.ini`, `~/.config/gtk-4.0/settings.ini`
  y `~/.gtkrc-2.0`. Para cambiarlo a mano, usa `lxappearance`.
- Fuente JetBrains Mono Nerd Font en la barra y en la terminal.

### Terminal: zsh + Oh My Zsh + Powerlevel10k

- `install.sh` instala **zsh** y lo deja como shell por defecto, clona
  **Oh My Zsh** en `~/.oh-my-zsh` y **Powerlevel10k** en `~/.powerlevel10k`.
- El prompt de p10k usa el logo de Arch, directorio, rama de git, estado,
  batería y hora.
- Para cambiar el estilo del prompt: `p10k configure`.
- **neofetch** se ejecuta al abrir cada terminal nueva (una vez por
  terminal). El instant prompt de p10k está desactivado para que la
  salida de neofetch no se borre al dibujar el prompt.
- Si vuelves a ejecutar `p10k configure`, deja el **instant prompt en
  `off`** (o borra el bloque que añada al principio de `~/.zshrc`); si no,
  el prompt puede borrar la salida de neofetch.
- Plugins: `git`, `sudo`, `extract`, `colored-man-pages`,
  `history-substring-search`, autosugerencias y resaltado de sintaxis.
- `eza` sustituye a `ls` con iconos, `bat` a `cat` con colores y `zoxide`
  añade `z carpeta` para saltar a directorios usados.
- Alacritty usa fondo `#0d1a25`, 92 % de opacidad, cursor de bloque sin
  parpadeo y JetBrains Mono Nerd Font 10.5.

### OpenCode remoto

El binario oficial de OpenCode **no puede ejecutarse en el E6400**: está
compilado para x86-64 con SSE4.2 y el Core 2 Duo T9600 solo llega a
SSE4.1. Al arrancarlo termina con `Illegal instruction`.

El servidor se queda en el PC de escritorio (Windows) y el portátil llega a
él por un túnel SSH inverso. Hay dos formas de usarlo:

- **Navegador**: `opencode-web` (o el icono **OpenCode** en rofi) abre
  Firefox en la interfaz web.
- **Terminal**: `opencode-term` (o **OpenCode Terminal** en rofi) abre
  Alacritty con la TUI oficial, sin navegador.

```
PC de escritorio (Windows)                         Portátil (Arch)
opencode service start (127.0.0.1:28894)
   |
   +-- ssh -R 28895:127.0.0.1:28894 --> 127.0.0.1:28895   (web)
   |
   +-- ssh -R 28896:127.0.0.1:7682 --> 127.0.0.1:28896   (TUI)
                                              |
                                    ttyd + ConPTY -> opencode
```

Para la TUI, Windows ejecuta un `ttyd` portátil (sin instalación ni
administrador) que crea un PTY con ConPTY y lanza OpenCode dentro. El
cliente `opencode-term` del portátil habla el WebSocket de `ttyd` y conecta
la terminal local con ese PTY. `ttyd` escucha solo en `127.0.0.1:7682` y el
túnel solo publica `127.0.0.1:28896`, así que no se abre nada a la red.

- La TUI comparte el servidor y las sesiones de la interfaz web: al abrir
  `opencode-term` puedes continuar una sesión existente con **Switch
  session** (`Ctrl + P`).
- `ttyd` es un binario portátil en
  `%USERPROFILE%\.opencode-remote\ttyd\ttyd.exe` (si falta, descárgalo de
  <https://github.com/tsl0922/ttyd/releases>, archivo `ttyd.win32.exe`) y
  se arranca al iniciar sesión con `start-tunnel.cmd`. No requiere UAC.
- En Windows, el servidor, `ttyd` y el túnel se levantan solos al iniciar
  sesión mediante `%USERPROFILE%\.opencode-remote\start-tunnel.cmd`.
- La primera vez hay que emparejar el navegador para la web. En Windows
  ejecuta `opencode pair --url http://127.0.0.1:28895` y abre el enlace en
  el portátil. La cookie dura 30 días. La TUI no necesita este paso:
  usa `service.json` y el servicio local.
- El PC de escritorio debe estar encendido y en la misma red. Si
  `opencode-web` o `opencode-term` avisan de que no hay conexión,
  comprueba en Windows que sigan vivos `opencode service status`, `ttyd.exe`
  y el proceso `ssh`.
- Al cerrar Alacritty se termina el proceso remoto de la TUI; las sesiones
  quedan guardadas en el servidor.
- La clave pública del PC está en `ssh/opencode-windows.pub`;
  `bash ssh/setup-key.sh` la autoriza en el portátil si hiciera falta.

### Fondos de pantalla

- Gestor propio con rofi + feh: `wallpaper-menu` (o el icono de imagen
  de la barra, o `Mod4 + Shift + W`) muestra todos los fondos y aplica el
  elegido al instante.
- `wallpaper-menu random` elige uno al azar.
- Se incluyen 5 fondos Catppuccin en `~/.config/awesome/wallpapers/`
  (azul, aurora, malva, bosque y atardecer). Puedes añadir los tuyos a
  `~/Pictures/Wallpapers/`.
- La elección se guarda en `~/.config/awesome/wallpaper.conf` y se vuelve
  a aplicar al arrancar (`~/.xinitrc` y autostart de awesome). Si algo
  falla, ejecuta `~/.local/bin/wallpaper-apply`.

### Flatpak

- **Flatpak** instalado con el repositorio **Flathub**, tanto a nivel de
  sistema como de usuario:
  ```bash
  flatpak search programa
  flatpak --user install flathub org.ejemplo.App   # se guarda en /home
  flatpak install flathub org.ejemplo.App          # a nivel de sistema
  flatpak update
  ```
- En este equipo conviene `--user`: así las apps no llenan la partición
  del sistema (32 GB) y se quedan en `/home` (260 GB).
- Las aplicaciones instaladas con Flatpak aparecen solas en rofi
  (`Mod4 + d`) gracias a los `.desktop` exportados.
- **Flatseal** puede arrancar sin mostrar ventana en esta GPU (GTK4 y
  DRI3). Fuerza el render por software solo para esa app:
  ```bash
  flatpak override --user --env=GSK_RENDERER=cairo com.github.tchx84.Flatseal
  ```
- **polkit-gnome** se instala con `install.sh` y awesome lo arranca al
  entrar. Es el encargado de pedir la contraseña cuando una app gráfica
  necesita permisos (instalar/actualizar paquetes, GParted, etc.).

### ArtCraft

- El launcher y sus apps vienen de un repositorio propio de ArtCraft, no
  de los repos oficiales de Arch. La configuración está en
  `/etc/pacman.d/artcraft.conf`.
- El launcher se actualiza solo con el botón **Actualizar y reiniciar**;
  las apps se instalan desde su interfaz. Ambas cosas usan `pkexec`, así
  que necesitan el agente **polkit-gnome** en marcha.

### neofetch

- `neofetch` está instalado en `/usr/local/bin/neofetch` (el paquete ya no
  está en los repos oficiales de Arch).
- Configuración en `~/.config/neofetch/config.conf` y logo propio en
  `~/.config/neofetch/ascii.txt`.
- Estilo **Catppuccin Macchiato**: logo Arch con degradado azul → malva →
  rosa, etiquetas en azul, valores en blanco y bloques de color del tema.
- Muestra sistema, núcleo, uptime, paquetes, shell, escritorio, pantalla,
  terminal, CPU, GPU, memoria, ambos discos, batería y red.
- Se ejecuta automáticamente al abrir una terminal nueva.
- También puedes usar el alias `fetch`.

### Almacenamiento y particiones

El disco del E6400 (Seagate ST9320325AS, 320 GB ≈ 298 GiB) está dividido
en tres particiones:

| Partición | Tamaño | Uso |
|---|---|---|
| `/dev/sda1` | 1 GB | `/boot` (arranque) |
| `/dev/sda2` | 32 GB | `/` (sistema; ~23 GB libres) |
| `/dev/sda3` | 260 GB | `/home` (datos; ~247 GB libres) |

No falta disco: el sistema ocupa 32 GB y tus archivos viven en `/home`
con 260 GB. La barra muestra el **espacio libre de `/home`**; al hacer
clic enseña el detalle de ambas particiones. Si instalas muchas apps
Flatpak, usa `flatpak --user install ...` para que se guarden en `/home`
y no llenen la partición del sistema.


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
- **ArtCraft falla al instalar con error 127**: no hay agente de polkit
  en la sesión gráfica. Instala `polkit-gnome`, reinicia awesome
  (`Mod4 + Ctrl + r`) y comprueba con `pgrep -a polkit-gnome`: debe
  aparecer en `session-2.scope` (la sesión de X11, no la de SSH).
- **Flatseal no muestra ventana**: GTK4 no encuentra DRI3 en esta GPU.
  Aplica el ajuste `GSK_RENDERER=cairo` de la sección Flatpak.
- **OpenCode termina con `Illegal instruction`**: el binario oficial
  necesita SSE4.2 y el T9600 solo tiene SSE4.1. No lo ejecutes en el
  portátil: usa `opencode-web` o `opencode-term` (ver «OpenCode remoto»).
- **`opencode-term` no conecta**: comprueba el túnel con
  `ss -ltn | grep 28896` y `curl -sI http://127.0.0.1:28896/`. Si no
  responde, el túnel está caído; `opencode-web` te lo confirma. En Windows
  revisa que `ttyd.exe` siga vivo y que el puerto 7682 esté en escucha.
- **Sin notificaciones**: awesome ya trae `naughty` con D-Bus; no instales
  `dunst` a la vez o se pelearán por el bus.
- **El fondo no se ve (queda negro)**: comprueba que `feh` está instalado
  (`pacman -Q feh`), que existe `~/.config/awesome/wallpaper.png` y ejecuta
  a mano:
  ```bash
  ~/.local/bin/wallpaper-apply
  feh --bg-fill ~/.config/awesome/wallpaper.png
  ```
  Si eso funciona pero al arrancar no, revisa que `~/.xinitrc` sea el que
  usa `startx`. Si `wallpaper.conf` apunta a una ruta antigua, bórralo o
  elige otro fondo con `Mod4 + Shift + W`.

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
