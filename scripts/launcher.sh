# shellcheck shell=bash
# Avid Kiya DevHub Startup Loader v3.2.0
# This file is sourced by ~/.bashrc.

AK_APP_DIR="${AK_APP_DIR:-$HOME/.termux-avid-kiya}"
AK_CONFIG="$AK_APP_DIR/config"
AK_AVID="$AK_APP_DIR/bin/avid"

# Defaults
AK_USE_LOLCAT="${AK_USE_LOLCAT:-1}"
AK_UTF8="${AK_UTF8:-1}"

[ -f "$AK_CONFIG" ] && . "$AK_CONFIG"

if [ "${AK_UTF8:-1}" = "1" ]; then
  export LANG="${LANG:-C.UTF-8}"
  export LC_ALL="${LC_ALL:-C.UTF-8}"
fi

# Make sure the new professional command is always available.
export PATH="$AK_APP_DIR/bin:$PATH"

ak_has() { command -v "$1" >/dev/null 2>&1; }
ak_color() { if [ "${AK_USE_LOLCAT:-1}" = "1" ] && ak_has lolcat; then lolcat; else cat; fi; }

ak_fallback_menu() {
  clear
  cat <<'MENU' | ak_color
╔════════════════════════════════════════════════════════════╗
║                    Avid Kiya DevHub                       ║
║       Termux + Ubuntu + AI + Dev + Cybersecurity Lab      ║
╚════════════════════════════════════════════════════════════╝

The full DevHub command was not found.
Run the installer again from the project folder:

  bash install.sh

MENU
}

ak_start_devhub() {
  if [ -x "$AK_AVID" ]; then
    "$AK_AVID" menu
  elif ak_has avid; then
    avid menu
  else
    ak_fallback_menu
  fi
}

# Run only in interactive Termux bash sessions and only once per session.
case "$-" in
  *i*)
    if [ -z "${AK_LAUNCHER_SHOWN:-}" ] && [ -n "${TERMUX_VERSION:-}${PREFIX:-}" ]; then
      export AK_LAUNCHER_SHOWN=1
      ak_start_devhub
    fi
    ;;
esac
