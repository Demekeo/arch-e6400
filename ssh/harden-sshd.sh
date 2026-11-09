#!/usr/bin/env bash
# Deja SSH solo con clave publica.
#
# Comprueba que hay al menos una clave autorizada, instala un drop-in de
# sshd, valida la configuracion con "sshd -t" y recarga el servicio. Si
# algo falla, no recarga y la sesion actual sigue funcionando.
#
# Uso:  cd ~/arch-e6400 && bash ssh/harden-sshd.sh
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  echo "Ejecutalo como tu usuario normal: pedira sudo solo para instalar."
  exit 1
fi

home="${HOME:-/home/$(id -un)}"
auth="$home/.ssh/authorized_keys"
if [ ! -s "$auth" ]; then
  echo "No hay claves en $auth."
  echo "Ejecuta antes: bash ssh/setup-key.sh"
  exit 1
fi
if ! ssh-keygen -lf "$auth" >/dev/null 2>&1; then
  echo "OJO: $auth no contiene una clave valida. No se toca sshd."
  exit 1
fi

echo "Esto desactivara el acceso SSH con contrasena."
echo "La clave de $auth seguira funcionando."
read -r -p "¿Continuar? [s/N] " reply
case "$reply" in
  s|S|si|SI|sí|SÍ) ;;
  *) echo "Cancelado."; exit 1 ;;
esac

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
cat >"$tmp" <<'EOF'
# Solo clave publica: el tunel de OpenCode ya usa clave.
# Si algun dia necesitas la contrasena, borra este archivo y recarga sshd.
PasswordAuthentication no
KbdInteractiveAuthentication no
EOF

echo ">> Instalando /etc/ssh/sshd_config.d/100-key-only.conf..."
sudo install -Dm644 "$tmp" /etc/ssh/sshd_config.d/100-key-only.conf
echo ">> Validando la configuracion de sshd..."
sudo sshd -t
echo ">> Recargando sshd..."
sudo systemctl reload sshd
echo
echo "Hecho. Antes de cerrar esta sesion, prueba desde el PC de escritorio:"
echo "  ssh -i C:\\Users\\tichu\\.ssh\\arch_e6400 demekeo@192.168.0.111 true"
echo "Si esa prueba funciona, la contrasena ya no es necesaria."
