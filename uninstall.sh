#!/usr/bin/env bash
set -euo pipefail

APP_DIR="$HOME/.termux-avid-kiya"
BASHRC="$HOME/.bashrc"
MARK_BEGIN="# >>> AVID_KIYA_TERMUX_UBUNTU_LAUNCHER >>>"
MARK_END="# <<< AVID_KIYA_TERMUX_UBUNTU_LAUNCHER <<<"

printf '[+] Removing launcher block from ~/.bashrc...\n'
if [ -f "$BASHRC" ]; then
  cp "$BASHRC" "$BASHRC.avid-uninstall-backup.$(date +%Y%m%d-%H%M%S)"
  tmpfile="$(mktemp)"
  awk -v begin="$MARK_BEGIN" -v end="$MARK_END" '
    $0 == begin {skip=1; next}
    $0 == end {skip=0; next}
    !skip {print}
  ' "$BASHRC" > "$tmpfile"
  cat "$tmpfile" > "$BASHRC"
  rm -f "$tmpfile"
fi

printf '[?] Remove launcher files at %s ? [y/N]: ' "$APP_DIR"
read -r answer
case "$answer" in
  y|Y|yes|YES) rm -rf "$APP_DIR"; printf '[✓] Removed %s\n' "$APP_DIR" ;;
  *) printf '[i] Kept %s\n' "$APP_DIR" ;;
esac

printf '\n[✓] Uninstall complete. Restart Termux.\n'
printf '[i] Ubuntu rootfs is NOT removed. To remove it manually run:\n'
printf '    proot-distro remove ubuntu\n'
