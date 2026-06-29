# shellcheck shell=bash
# Avid Kiya Termux/Ubuntu Launcher v1.2.0
# This script is sourced by ~/.bashrc.

AK_APP_DIR="${AK_APP_DIR:-$HOME/.termux-avid-kiya}"
AK_CONFIG="$AK_APP_DIR/config"

# Defaults. User config can override them.
AK_WTTR_LOCATION="${AK_WTTR_LOCATION:-36.46,52.86}"
AK_NAME="${AK_NAME:-Avid Kiya}"
AK_UBUNTU_DISTRO="${AK_UBUNTU_DISTRO:-ubuntu}"
AK_AUTO_FISH_AFTER_TERMUX="${AK_AUTO_FISH_AFTER_TERMUX:-0}"
AK_USE_LOLCAT="${AK_USE_LOLCAT:-1}"
AK_UTF8="${AK_UTF8:-1}"

[ -f "$AK_CONFIG" ] && . "$AK_CONFIG"

if [ "${AK_UTF8:-1}" = "1" ]; then
  export LANG="${LANG:-C.UTF-8}"
  export LC_ALL="${LC_ALL:-C.UTF-8}"
fi

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

ak_cols() {
  tput cols 2>/dev/null || echo 80
}

ak_weather() {
  if ak_has curl; then
    curl -s --connect-timeout 8 "wttr.in/${AK_WTTR_LOCATION}" | head -7 || true
  else
    echo "Weather report: curl is not installed"
  fi
}

ak_prop() {
  getprop "$1" 2>/dev/null | head -n 1
}

ak_ram() {
  free -m 2>/dev/null | awk '/Mem:/ {print $3"MiB / "$2"MiB"}' || echo "unknown"
}

ak_android_info() {
  local os device code rom kernel uptime cpu ram
  os="Android $(ak_prop ro.build.version.release)"
  [ "$os" = "Android " ] && os="Android unknown"
  device="$(ak_prop ro.product.model)"
  [ -z "$device" ] && device="unknown"
  code="$(ak_prop ro.product.device)"
  [ -z "$code" ] && code="unknown"
  rom="$(ak_prop ro.build.id)"
  [ -z "$rom" ] && rom="unknown"
  kernel="$(uname -m) Linux $(uname -r)"
  uptime="$(uptime -p 2>/dev/null | sed 's/^up //' || true)"
  cpu="$(ak_prop ro.hardware)"
  [ -z "$cpu" ] && cpu="$(uname -m)"
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

ak_termux_title_compact() {
  cat <<'EOF2'
╔══════════════════════════════════════╗
║              TERMUX                  ║
╚══════════════════════════════════════╝
             === Avid Kiya ===
EOF2
}

ak_menu_art_full() {
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
3. ⚙️ Ubuntu installer / patcher
4. 🚪 Exit - Opening Termux normally
EOF2
}

ak_menu_art_compact() {
  cat <<'EOF2'
        .--.             ╲ ▁▂▂▂▁ ╱
       |o_o |            ▄███████▄
       |:_/ |           ▄██ ███ ██▄
      //   \ \         ▄███████████▄
     (|     | )        ██ █████████ ██
      \___/             ███████████

╔══════════════════════════════════════╗
║             AVID KIYA                ║
║           Termux - Ubuntu            ║
╚══════════════════════════════════════╝

1. 🐧 Run Termux
2. ☣️ Run Ubuntu
3. ⚙️ Ubuntu installer / patcher
4. 🚪 Exit - Opening Termux normally
EOF2
}

ak_termux_banner() {
  clear
  if ak_has screenfetch; then
    screenfetch | ak_color
  else
    ak_android_info | ak_color
  fi
  echo
  if [ "$(ak_cols)" -lt 62 ]; then
    ak_termux_title_compact | ak_color
  else
    ak_termux_title | ak_color
  fi
  ak_weather
  date | ak_color
  uname -a
  export PS1='^^>>> '
}

ak_ubuntu_exists() {
  ak_has proot-distro || return 1
  proot-distro login "${AK_UBUNTU_DISTRO}" -- /bin/true >/dev/null 2>&1
}

ak_ubuntu_patch() {
  echo "[+] Updating Ubuntu and applying PATH/development patch..."
  proot-distro login "${AK_UBUNTU_DISTRO}" -- bash -lc '
    set -e
    export DEBIAN_FRONTEND=noninteractive
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
    apt update
    apt install -y \
      bash curl wget git nano ca-certificates sudo \
      patch make gcc g++ build-essential pkg-config \
      python3 python3-pip python3-venv \
      procps util-linux coreutils findutils grep sed gawk tar gzip unzip \
      iproute2 net-tools dnsutils openssl locales

    locale-gen C.UTF-8 >/dev/null 2>&1 || true

    cat > /etc/profile.d/avid-kiya-path.sh <<"EOF_INNER"
# Avid Kiya Termux Ubuntu PATH patch
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
EOF_INNER

    chmod +x /etc/profile.d/avid-kiya-path.sh || true

    touch /root/.bashrc
    if ! grep -q "avid-kiya-path" /root/.bashrc 2>/dev/null; then
      cat >> /root/.bashrc <<"EOF_INNER"

# Avid Kiya PATH patch
[ -f /etc/profile.d/avid-kiya-path.sh ] && . /etc/profile.d/avid-kiya-path.sh
EOF_INNER
    fi
  '
}

ak_install_fresh_ubuntu() {
  echo "[+] Installing Ubuntu container: ${AK_UBUNTU_DISTRO}"
  proot-distro install "${AK_UBUNTU_DISTRO}"
}

ak_reinstall_ubuntu() {
  echo "[!] This will REMOVE the existing Ubuntu container and all files inside it."
  printf "Type REINSTALL to continue: "
  read -r confirm
  if [ "$confirm" != "REINSTALL" ]; then
    echo "[i] Reinstall cancelled."
    return 1
  fi
  proot-distro remove "${AK_UBUNTU_DISTRO}" || true
  ak_install_fresh_ubuntu
}

ak_install_ubuntu() {
  clear
  echo "=== Ubuntu installer / patcher ==="

  if ! ak_has proot-distro; then
    echo "[+] Installing proot-distro first..."
    pkg install -y proot-distro
  fi

  if ak_ubuntu_exists; then
    echo "[i] Ubuntu container already exists and login works."
    echo
    echo "1. Patch/Update existing Ubuntu (keep files)"
    echo "2. Reinstall Ubuntu from zero (DELETE Ubuntu files)"
    echo "3. Back"
    printf "Choose option [1-3]: "
    read -r u_choice
    case "$u_choice" in
      1) ak_ubuntu_patch ;;
      2) ak_reinstall_ubuntu && ak_ubuntu_patch ;;
      3) return ;;
      *) echo "Invalid option. Back."; ak_pause; return ;;
    esac
  else
    echo "[i] Ubuntu login test failed or Ubuntu is not installed."
    echo "[+] Trying fresh install..."
    if ! ak_install_fresh_ubuntu; then
      echo "[!] Fresh install failed. If proot-distro says container exists, it may be broken."
      echo
      echo "1. Try Patch/Repair existing container"
      echo "2. Reinstall Ubuntu from zero (DELETE Ubuntu files)"
      echo "3. Back"
      printf "Choose option [1-3]: "
      read -r fix_choice
      case "$fix_choice" in
        1) ;;
        2) ak_reinstall_ubuntu ;;
        3) return ;;
        *) echo "Invalid option. Back."; ak_pause; return ;;
      esac
    fi
    ak_ubuntu_patch
  fi

  echo "[✓] Ubuntu is installed/patched and ready. Use option 2 to enter Ubuntu."
  ak_pause
}

ak_run_ubuntu() {
  if ! ak_has proot-distro; then
    echo "proot-distro is not installed. Choose option 3 first."
    ak_pause
    return
  fi

  if ! ak_ubuntu_exists; then
    echo "Ubuntu is not ready or login test failed. Choose option 3 first."
    ak_pause
    return
  fi

  proot-distro login "${AK_UBUNTU_DISTRO}" -- env AK_WTTR_LOCATION="$AK_WTTR_LOCATION" bash -lc 'cat > /tmp/avid-kiya-ubuntu-rc.sh <<'"'"'AK_UBUNTU_RC_EOF'"'"'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
[ -f /etc/profile.d/avid-kiya-path.sh ] && . /etc/profile.d/avid-kiya-path.sh
clear
cat <<'"'"'EOF2'"'"'
       .--.    
      |o_o |   
      |:_/ |   
     //   \ \        OS: Ubuntu/proot
    (|     | )       Host: Termux Android
   /'"'"'\_   _/`\       Kernel: Android/Linux kernel
   \___)=(___/       Shell: bash
      .-"""-.        PATH: patched
     / .===. \       Tools: patch/build-essential
     \/ 6 6 \/       Mode: proot-distro
     ( \___/ )
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
echo "PATH=$PATH"
export PS1=">>> "
AK_UBUNTU_RC_EOF
exec bash --rcfile /tmp/avid-kiya-ubuntu-rc.sh -i'
}

ak_show_menu() {
  clear
  if [ "$(ak_cols)" -lt 66 ]; then
    ak_menu_art_compact | ak_color
  else
    ak_menu_art_full | ak_color
  fi
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
