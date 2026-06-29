# shellcheck shell=bash
# Avid Kiya Termux/Ubuntu Launcher v2.1.0
# This script is sourced by ~/.bashrc.

AK_APP_DIR="${AK_APP_DIR:-$HOME/.termux-avid-kiya}"
AK_CONFIG="$AK_APP_DIR/config"

AK_WTTR_LOCATION="${AK_WTTR_LOCATION:-36.46,52.86}"
AK_NAME="${AK_NAME:-Avid Kiya}"
AK_UBUNTU_DISTRO="${AK_UBUNTU_DISTRO:-ubuntu}"
AK_AUTO_FISH_AFTER_TERMUX="${AK_AUTO_FISH_AFTER_TERMUX:-1}"
AK_USE_LOLCAT="${AK_USE_LOLCAT:-1}"
AK_UTF8="${AK_UTF8:-1}"
AK_CLASSIC_TERMUX_THEME="${AK_CLASSIC_TERMUX_THEME:-0}"
AK_MATCHED_BANNERS="${AK_MATCHED_BANNERS:-1}"
AK_INSTALL_MIMO="${AK_INSTALL_MIMO:-1}"
AK_AUTO_FISH_AFTER_UBUNTU="${AK_AUTO_FISH_AFTER_UBUNTU:-1}"

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

ak_pause() { printf '\nPress Enter to continue...'; read -r _ak_dummy || true; }
ak_cols() { tput cols 2>/dev/null || echo 80; }

ak_weather() {
  if ak_has curl; then
    curl -s --connect-timeout 8 "wttr.in/${AK_WTTR_LOCATION}" | head -7 || true
  else
    echo "Weather report: curl is not installed"
  fi
}

ak_prop() { getprop "$1" 2>/dev/null | head -n 1; }
ak_ram() { free -m 2>/dev/null | awk '/Mem:/ {print $3"MiB / "$2"MiB"}' || echo "unknown"; }

ak_android_info() {
  local os device code rom kernel uptime cpu ram
  os="Android $(ak_prop ro.build.version.release)"; [ "$os" = "Android " ] && os="Android unknown"
  device="$(ak_prop ro.product.model)"; [ -z "$device" ] && device="unknown"
  code="$(ak_prop ro.product.device)"; [ -z "$code" ] && code="unknown"
  rom="$(ak_prop ro.build.id)"; [ -z "$rom" ] && rom="unknown"
  kernel="$(uname -m) Linux $(uname -r)"
  uptime="$(uptime -p 2>/dev/null | sed 's/^up //' || true)"
  cpu="$(ak_prop ro.hardware)"; [ -z "$cpu" ] && cpu="$(uname -m)"
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
║                TERMUX                ║
╚══════════════════════════════════════╝
             === Avid Kiya ===
EOF2
}

ak_classic_avid_title() {
  if ak_has figlet; then figlet '+ Avid Kiya +'; else echo '=== Avid Kiya ==='; fi
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
3. ⚙️ Ubuntu installer / patcher / MiMo fixer
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
3. ⚙️ Ubuntu installer / patcher / MiMo fixer
4. 🚪 Exit - Opening Termux normally
EOF2
}

ak_termux_banner() {
  clear
  ak_android_info | ak_color
  echo
  if [ "${AK_CLASSIC_TERMUX_THEME:-0}" = "1" ]; then
    ak_classic_avid_title | ak_color
  else
    if [ "$(ak_cols)" -lt 62 ]; then ak_termux_title_compact | ak_color; else ak_termux_title | ak_color; fi
  fi
  ak_weather
  date | ak_color
  uname -a
  export PS1='^^>>> '
}

ak_open_fish_if_enabled() {
  if [ "${AK_AUTO_FISH_AFTER_TERMUX:-1}" = "1" ] && ak_has fish; then exec fish; fi
}

ak_ubuntu_exists() {
  ak_has proot-distro || return 1
  proot-distro login "${AK_UBUNTU_DISTRO}" -- /bin/true >/dev/null 2>&1
}

ak_install_fresh_ubuntu() { echo "[+] Installing Ubuntu container: ${AK_UBUNTU_DISTRO}"; proot-distro install "${AK_UBUNTU_DISTRO}"; }

ak_reinstall_ubuntu() {
  echo "[!] This will REMOVE the existing Ubuntu container and all files inside it."
  printf "Type REINSTALL to continue: "; read -r confirm
  [ "$confirm" = "REINSTALL" ] || { echo "[i] Reinstall cancelled."; return 1; }
  proot-distro remove "${AK_UBUNTU_DISTRO}" || true
  ak_install_fresh_ubuntu
}

ak_ubuntu_patch() {
  echo "[+] Updating Ubuntu and applying PATH/development/MiMo patch..."
  proot-distro login "${AK_UBUNTU_DISTRO}" -- env AK_INSTALL_MIMO="$AK_INSTALL_MIMO" bash -lc '
    set +e
    export DEBIAN_FRONTEND=noninteractive
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

    apt update
    apt install -y \
      bash fish curl wget git nano ca-certificates sudo ruby ruby-dev \
      patch make gcc g++ build-essential pkg-config cmake \
      python3 python3-pip python3-venv python3-dev pipx \
      nodejs npm \
      procps util-linux coreutils findutils grep sed gawk tar gzip unzip xz-utils \
      iproute2 net-tools dnsutils openssl locales sqlite3 jq ripgrep fd-find

    locale-gen C.UTF-8 >/dev/null 2>&1 || true

    # Try to upgrade Node.js to a modern version when the Ubuntu package is too old.
    NODE_MAJOR="$(node -v 2>/dev/null | sed 's/^v//' | cut -d. -f1)"
    if [ -z "$NODE_MAJOR" ] || [ "$NODE_MAJOR" -lt 20 ] 2>/dev/null; then
      echo "[+] Trying NodeSource Node.js 22 setup for MiMo..."
      curl -fsSL https://deb.nodesource.com/setup_22.x | bash - || true
      apt install -y nodejs || true
    fi

    # lolcat inside Ubuntu for the same colorful style.
    if ! command -v lolcat >/dev/null 2>&1; then
      gem install lolcat --no-document || true
    fi

    # Oh My Fish + batman theme inside Ubuntu.
    # This makes Ubuntu use the same helpful fish/batman guide-style prompt.
    if command -v fish >/dev/null 2>&1; then
      echo "[+] Installing Oh My Fish and batman theme inside Ubuntu..."
      fish -lc 'type -q omf; or curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish' || true
      fish -lc 'omf install batman; or true' || true
      fish -lc 'omf theme batman; or omf batman; or true' || true

      mkdir -p /root/.config/fish/conf.d
      cat > /root/.config/fish/conf.d/avid-kiya-path.fish <<"EOF_FISH"
# Avid Kiya PATH patch for Ubuntu fish
set -gx PATH /root/.mimocode/bin /root/.npm-global/bin /root/.local/bin /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin $PATH
set -gx LANG C.UTF-8
set -gx LC_ALL C.UTF-8
EOF_FISH
    fi

    cat > /etc/profile.d/avid-kiya-path.sh <<"EOF_INNER"
# Avid Kiya Termux Ubuntu PATH patch
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.mimocode/bin:/root/.npm-global/bin:/root/.local/bin:$PATH"
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
EOF_INNER
    chmod +x /etc/profile.d/avid-kiya-path.sh || true

    touch /root/.bashrc
    if ! grep -q "avid-kiya-path" /root/.bashrc 2>/dev/null; then
      cat >> /root/.bashrc <<"EOF_INNER"

# Avid Kiya PATH patch
[ -f /etc/profile.d/avid-kiya-path.sh ] && . /etc/profile.d/avid-kiya-path.sh
[ -f /root/.bashrc ] && . /root/.bashrc
EOF_INNER
    fi

    . /etc/profile.d/avid-kiya-path.sh

    # MiMo Code fix/install.
    # Important: official installer can place binary in /root/.mimocode/bin/mimo.
    # We add that directory to PATH, source /root/.bashrc, and create a safe symlink.
    if [ "${AK_INSTALL_MIMO:-1}" = "1" ]; then
      echo "[+] Installing/repairing MiMo Code..."
      export PATH="/root/.mimocode/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.npm-global/bin:/root/.local/bin:$PATH"

      # Prefer official installer because it creates /root/.mimocode/bin/mimo on many systems.
      curl -fsSL https://mimo.xiaomi.com/install | bash || true

      # Also try npm package as fallback/alternative.
      npm config set prefix /usr/local || true
      npm install -g npm@latest || true
      npm install -g @mimo-ai/cli || true

      # Permanent PATH for bash login/non-login shells.
      if ! grep -q "/root/.mimocode/bin" /root/.bashrc 2>/dev/null; then
        cat >> /root/.bashrc <<"EOF_INNER"

# MiMo Code PATH
export PATH="/root/.mimocode/bin:$PATH"
EOF_INNER
      fi

      # Create command symlink if binary exists in official location.
      if [ -x /root/.mimocode/bin/mimo ]; then
        ln -sf /root/.mimocode/bin/mimo /usr/local/bin/mimo || true
      fi

      # Reload bashrc as requested by MiMo fix instructions.
      . /root/.bashrc 2>/dev/null || true
      hash -r 2>/dev/null || true

      if command -v mimo >/dev/null 2>&1; then
        echo "[✓] MiMo installed/fixed: $(command -v mimo)"
        mimo --version 2>/dev/null || true
      elif [ -x /root/.mimocode/bin/mimo ]; then
        echo "[✓] MiMo exists at /root/.mimocode/bin/mimo"
        echo "[i] PATH was patched. Restart Ubuntu shell or run: source /root/.bashrc"
      else
        echo "[!] MiMo is still not available. Network/npm/architecture may have failed."
        echo "[i] Try manually inside Ubuntu: curl -fsSL https://mimo.xiaomi.com/install | bash"
      fi
    fi
  '
}

ak_install_ubuntu() {
  clear
  echo "=== Ubuntu installer / patcher / MiMo fixer ==="
  if ! ak_has proot-distro; then echo "[+] Installing proot-distro first..."; pkg install -y proot-distro; fi

  if ak_ubuntu_exists; then
    echo "[i] Ubuntu container already exists and login works."
    echo
    echo "1. Patch/Update existing Ubuntu + fix MiMo (keep files)"
    echo "2. Reinstall Ubuntu from zero (DELETE Ubuntu files)"
    echo "3. Back"
    printf "Choose option [1-3]: "; read -r u_choice
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
      echo "[!] Fresh install failed. If container exists, it may be broken."
      echo "1. Try Patch/Repair existing container"
      echo "2. Reinstall Ubuntu from zero (DELETE Ubuntu files)"
      echo "3. Back"
      printf "Choose option [1-3]: "; read -r fix_choice
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
  if ! ak_has proot-distro; then echo "proot-distro is not installed. Choose option 3 first."; ak_pause; return; fi
  if ! ak_ubuntu_exists; then echo "Ubuntu is not ready or login test failed. Choose option 3 first."; ak_pause; return; fi

  proot-distro login "${AK_UBUNTU_DISTRO}" -- env AK_WTTR_LOCATION="$AK_WTTR_LOCATION" AK_AUTO_FISH_AFTER_UBUNTU="$AK_AUTO_FISH_AFTER_UBUNTU" bash -lc 'cat > /tmp/avid-kiya-ubuntu-rc.sh <<'"'"'AK_UBUNTU_RC_EOF'"'"'
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.mimocode/bin:/root/.npm-global/bin:/root/.local/bin:$PATH"
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
[ -f /etc/profile.d/avid-kiya-path.sh ] && . /etc/profile.d/avid-kiya-path.sh
[ -f /root/.bashrc ] && . /root/.bashrc
ak_ubuntu_color() { if command -v lolcat >/dev/null 2>&1; then lolcat; else cat; fi; }
clear
{
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
} | ak_ubuntu_color
if command -v curl >/dev/null 2>&1; then curl -s --connect-timeout 8 "wttr.in/${AK_WTTR_LOCATION:-36.46,52.86}" | head -7 || true; fi
date | ak_ubuntu_color
uname -a
if command -v mimo >/dev/null 2>&1; then echo "MiMo: $(command -v mimo)"; elif [ -x /root/.mimocode/bin/mimo ]; then echo "MiMo: /root/.mimocode/bin/mimo"; else echo "MiMo: not installed - run menu option 3 then choose Patch/Update"; fi
if [ "${AK_AUTO_FISH_AFTER_UBUNTU:-1}" = "1" ] && command -v fish >/dev/null 2>&1; then
  echo "Shell: opening fish + Oh My Fish batman theme..."
  exec fish -l
fi
export PS1=">>> "
AK_UBUNTU_RC_EOF
exec bash --rcfile /tmp/avid-kiya-ubuntu-rc.sh -i'
}

ak_show_menu() {
  clear
  if [ "$(ak_cols)" -lt 66 ]; then ak_menu_art_compact | ak_color; else ak_menu_art_full | ak_color; fi
  printf '\nChoose option [1-4]: '; read -r ak_choice
  case "$ak_choice" in
    1) ak_termux_banner; ak_open_fish_if_enabled ;;
    2) ak_run_ubuntu ;;
    3) ak_install_ubuntu ;;
    4) clear ;;
    *) echo "Invalid option. Opening Termux normally." ;;
  esac
}

case "$-" in
  *i*)
    if [ -z "${AK_LAUNCHER_SHOWN:-}" ] && [ -n "${TERMUX_VERSION:-}${PREFIX:-}" ]; then
      export AK_LAUNCHER_SHOWN=1
      ak_show_menu
    fi
    ;;
esac
