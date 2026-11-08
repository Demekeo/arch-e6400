#!/usr/bin/env bash
# Instala la clave publica de OpenCode en ~/.ssh/authorized_keys.
# Uso:  cd ~/arch-e6400 && bash ssh/setup-key.sh
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
keyfile="$here/opencode-windows.pub"
key="$(cat "$keyfile")"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"

if grep -qxF "$key" "$HOME/.ssh/authorized_keys"; then
  echo "La clave ya estaba instalada."
else
  printf '%s\n' "$key" >> "$HOME/.ssh/authorized_keys"
  echo "Clave instalada en ~/.ssh/authorized_keys"
fi
