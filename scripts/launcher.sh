# shellcheck shell=bash
# Avid Kiya Termux/Ubuntu Launcher
# This script is sourced by ~/.bashrc. Do not run directly unless you know what you do.

AK_APP_DIR="${AK_APP_DIR:-$HOME/.termux-avid-kiya}"
AK_CONFIG="$AK_APP_DIR/config"

# Defaults. User config can override them.
AK_WTTR_LOCATION="${AK_WTTR_LOCATION:-36.46,52.86}"
AK_NAME="${AK_NAME:-Avid Kiya}"
AK_UBUNTU_DISTRO="${AK_UBUNTU_DISTRO:-ubuntu}"
AK_AUTO_FISH_AFTER_TERMUX="${AK_AUTO_FISH_AFTER_TERMUX:-0}"
AK_USE_LOLCAT="${AK_USE_LOLCAT:-1}"

[ -f "$AK_CONFIG" ] && . "$AK_CONFIG"

ak_has() { command -v "$1" >/dev/null 2>&1; }

ak_color() {
  if [ "${AK_USE_LOLCAT:-1}" = "1" ] && ak_has lolcat; then
    lolcat
  else
    cat
  fi
}

ak_pause() {
  printf '\nPress Enter to continue...'
  read -r _ak_dummy || true
}

ak_weather() {
  if ak_has curl; then
    curl -s --connect-timeout 8 "wttr.in/${AK_WTTR_LOCATION}" | head -7 || true
  else
    echo "Weather report: curl is not installed"
  fi
}

ak_ram() {
  free -m 2>/dev/null | awk '/Mem:/ {print $3"MiB / "$2"MiB"}' || echo "unknown"
}

ak_android_fallback() {
  local os device code rom kernel uptime cpu ram
  os="Android $(getprop ro.build.version.release 2>/dev/null || echo '?')"
  device="$(getprop ro.product.model 2>/dev/null || echo 'unknown')"
  code="$(getprop ro.product.device 2>/dev/null || echo 'unknown')"
  rom="$(getprop ro.build.id 2>/dev/null || echo 'unknown')"
  kernel="$(uname -m) Linux $(uname -r)"
  uptime="$(uptime -p 2>/dev/null | sed 's/^up //' || true)"
  cpu="$(getprop ro.hardware 2>/dev/null || uname -m)"
  ram="$(ak_ram)"
  cat <<EOF2
       ╲ ▁▂▂▂▁ ╱
       ▄███████▄
      ▄██ ███ ██▄
     ▄███████████▄       OS: ${os}
  ▄█ ▄▄▄▄▄▄▄▄▄▄▄▄▄ █▄    Device: ${device} (${code})
  ██ █████████████ ██    ROM: ${rom}
  ██ █████████████ ██    Baseband: unknown
  ██ █████████████ ██    Kernel: ${kernel}
  ██ █████████████ ██    Uptime: ${uptime}
     █████████████       CPU: ${cpu}
      ███████████        GPU: ${cpu}
       ██     ██         RAM: ${ram}
       ██     ██
EOF2
}

ak_termux_title() {
  cat <<'EOF2'
╔─────────────────────────────────────────────────────╗
│████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗│
│╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝│
│   ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ │
│   ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ │
│   ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗│
│   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝│
╚─────────────────────────────────────────────────────╝
                    === Avid Kiya === 
EOF2
}

ak_ubuntu_title() {
  cat <<'EOF2'
╔──────────────────────────────────────────────────────╗
│██╗   ██╗██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗│
│██║   ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║   ██║│
│██║   ██║██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║   ██║│
│██║   ██║██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║   ██║│
│╚██████╔╝██████╔╝╚██████╔╝██║ ╚████║   ██║   ╚██████╔╝│
│ ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝    ╚═════╝ │
╚──────────────────────────────────────────────────────╝
                    === Avid Kiya === 
EOF2
}

ak_menu_art() {
  cat <<'EOF2'
               .--.                  ╲ ▁▂▂▂▁ ╱
              |o_o |                 ▄███████▄
              |:_/ |                ▄██ ███ ██▄
             //   \ \              ▄███████████▄
            (|     | )          ▄█ ▄▄▄▄▄▄▄▄▄▄▄▄▄ █▄
           /'\_   _/`\          ██ █████████████ ██
           \___)=(___/          ██ █████████████ ██
              .-"""-.           ██ █████████████ ██
             / .===. \          ██ █████████████ ██
             \/ 6 6 \/             █████████████
             ( \___/ )              ███████████
        ___ooo__V__ooo___            ██     ██
                                     ██     ██
╔────────────────────────────────────────────────────────────╗
│ █████╗ ██╗   ██╗██╗██████╗     ██╗  ██╗██╗██╗   ██╗ █████╗ │
│██╔══██╗██║   ██║██║██╔══██╗    ██║ ██╔╝██║╚██╗ ██╔╝██╔══██╗│
│███████║██║   ██║██║██║  ██║    █████╔╝ ██║ ╚████╔╝ ███████║│
│██╔══██║╚██╗ ██╔╝██║██║  ██║    ██╔═██╗ ██║  ╚██╔╝  ██╔══██║│
│██║  ██║ ╚████╔╝ ██║██████╔╝    ██║  ██╗██║   ██║   ██║  ██║│
│╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═════╝     ╚═╝  ╚═╝╚═╝   ╚═╝   ╚═╝  ╚═╝│
╚────────────────────────────────────────────────────────────╝

                      Termux - Ubuntu

1. 🐧 Run Termux
2. ☣️ Run Ubuntu
3. ⚙️ Ubuntu installer
4. 🚪 Exit - Opening Termux normally
EOF2
}

ak_termux_banner() {
  clear
  if ak_has screenfetch; then
    screenfetch | ak_color
  else
    ak_android_fallback | ak_color
  fi
  echo
  ak_termux_title | ak_color
  ak_weather
  date | ak_color
  uname -a
  export PS1='^^>>> '
}

ak_ubuntu_installed() {
  [ -d "${PREFIX:-/data/data/com.termux/files/usr}/var/lib/proot-distro/installed-rootfs/${AK_UBUNTU_DISTRO}" ]
}

ak_install_ubuntu() {
  clear
  echo "[+] Installing Ubuntu with proot-distro..."

  if ! ak_has proot-distro; then
    echo "[+] Installing proot-distro first..."
    pkg install -y proot-distro
  fi

  if ak_ubuntu_installed; then
    echo "[i] Ubuntu is already installed."
  else
    proot-distro install "${AK_UBUNTU_DISTRO}"
  fi

  echo "[+] Preparing Ubuntu packages..."
  proot-distro login "${AK_UBUNTU_DISTRO}" -- bash -lc 'apt update && apt install -y curl ca-certificates bash'

  echo "[✓] Ubuntu is ready. Use option 2 to enter Ubuntu."
  ak_pause
}

ak_run_ubuntu() {
  if ! ak_has proot-distro; then
    echo "proot-distro is not installed. Choose option 3 first."
    ak_pause
    return
  fi

  if ! ak_ubuntu_installed; then
    echo "Ubuntu is not installed yet. Choose option 3 first."
    ak_pause
    return
  fi

  # Run a real Ubuntu shell with a startup rcfile.
  # Note: in Termux/proot the kernel is still Android's kernel, not a real PC kernel.
  proot-distro login "${AK_UBUNTU_DISTRO}" -- env AK_WTTR_LOCATION="$AK_WTTR_LOCATION" bash -lc 'cat > /tmp/avid-kiya-ubuntu-rc.sh <<'"'"'AK_UBUNTU_RC_EOF'"'"'
clear
cat <<'"'"'EOF2'"'"'
       .--.    
      |o_o |   
      |:_/ |   
     //   \ \        OS: Ubuntu 24.04 LTS
    (|     | )       Host: proot-distro on Termux
   /'"'"'\_   _/`\       Kernel: Android/Linux kernel
   \___)=(___/       Shell: bash
      .-"""-.        DE: none/proot
     / .===. \       WM: none/proot
     \/ 6 6 \/       Theme: terminal
     ( \___/ )       Icons: terminal
___ooo__V__ooo_________________________________________
╔──────────────────────────────────────────────────────╗
│██╗   ██╗██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗│
│██║   ██║██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║   ██║│
│██║   ██║██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║   ██║│
│██║   ██║██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║   ██║│
│╚██████╔╝██████╔╝╚██████╔╝██║ ╚████║   ██║   ╚██████╔╝│
│ ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝    ╚═════╝ │
╚──────────────────────────────────────────────────────╝
                    === Avid Kiya === 
EOF2
if command -v curl >/dev/null 2>&1; then
  curl -s --connect-timeout 8 "wttr.in/${AK_WTTR_LOCATION:-36.46,52.86}" | head -7 || true
fi
date
uname -a
export PS1=">>> "
AK_UBUNTU_RC_EOF
exec bash --rcfile /tmp/avid-kiya-ubuntu-rc.sh -i'
}

ak_show_menu() {
  clear
  ak_menu_art | ak_color
  printf '\nChoose option [1-4]: '
  read -r ak_choice

  case "$ak_choice" in
    1)
      ak_termux_banner
      if [ "${AK_AUTO_FISH_AFTER_TERMUX:-0}" = "1" ] && ak_has fish; then
        exec fish
      fi
      ;;
    2)
      ak_run_ubuntu
      ;;
    3)
      ak_install_ubuntu
      ;;
    4)
      clear
      ;;
    *)
      echo "Invalid option. Opening Termux normally."
      ;;
  esac
}

# Run only in interactive Termux bash sessions and only once per session.
case "$-" in
  *i*)
    if [ -z "${AK_LAUNCHER_SHOWN:-}" ] && [ -n "${TERMUX_VERSION:-}${PREFIX:-}" ]; then
      export AK_LAUNCHER_SHOWN=1
      ak_show_menu
    fi
    ;;
esac
