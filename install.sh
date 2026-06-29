#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/.termux-avid-kiya"
LAUNCHER_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/launcher.sh"
CONFIG_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config.example"
LAUNCHER_DST="$APP_DIR/launcher.sh"
CONFIG_DST="$APP_DIR/config"
BASHRC="$HOME/.bashrc"
MARK_BEGIN="# >>> AVID_KIYA_TERMUX_UBUNTU_LAUNCHER >>>"
MARK_END="# <<< AVID_KIYA_TERMUX_UBUNTU_LAUNCHER <<<"

msg() { printf '%s\n' "$*"; }

if ! command -v pkg >/dev/null 2>&1; then
  msg "[!] This installer is made for Termux. 'pkg' command was not found."
  exit 1
fi

if [ ! -f "$LAUNCHER_SRC" ]; then
  msg "[!] Cannot find scripts/launcher.sh. Run install.sh from the project folder."
  exit 1
fi

msg "[+] Creating app directory: $APP_DIR"
mkdir -p "$APP_DIR"

msg "[+] Updating Termux packages..."
pkg update -y || true

msg "[+] Installing required packages..."
pkg install -y curl figlet ruby fish proot-distro ncurses-utils || true

# screenfetch might not exist in every Termux repo. Try but do not fail.
pkg install -y screenfetch || true

if ! command -v lolcat >/dev/null 2>&1; then
  msg "[+] Installing lolcat via Ruby gem..."
  gem install lolcat --no-document || true
fi

msg "[+] Installing launcher files..."
cp "$LAUNCHER_SRC" "$LAUNCHER_DST"
chmod +x "$LAUNCHER_DST"

if [ ! -f "$CONFIG_DST" ]; then
  cp "$CONFIG_SRC" "$CONFIG_DST"
else
  msg "[i] Existing config kept: $CONFIG_DST"
fi

msg "[+] Backing up ~/.bashrc..."
touch "$BASHRC"
cp "$BASHRC" "$BASHRC.avid-backup.$(date +%Y%m%d-%H%M%S)"

msg "[+] Adding launcher to ~/.bashrc..."
tmpfile="$(mktemp)"
awk -v begin="$MARK_BEGIN" -v end="$MARK_END" '
  $0 == begin {skip=1; next}
  $0 == end {skip=0; next}
  !skip {print}
' "$BASHRC" > "$tmpfile"
cat "$tmpfile" > "$BASHRC"
rm -f "$tmpfile"

cat >> "$BASHRC" <<EOF2

$MARK_BEGIN
# Avid Kiya Termux/Ubuntu launcher
if [ -f "$LAUNCHER_DST" ]; then
  . "$LAUNCHER_DST"
fi
$MARK_END
EOF2

msg ""
msg "[✓] Installed successfully."
msg "[i] Launcher: $LAUNCHER_DST"
msg "[i] Config:   $CONFIG_DST"
msg "[i] Bashrc:   $BASHRC"
msg ""
msg "Now restart Termux or run:"
msg "  source ~/.bashrc"
msg ""
msg "Use menu option 3 once to install Ubuntu, then option 2 to run it."
