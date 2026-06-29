# shellcheck shell=bash
# Avid Kiya Termux/Ubuntu Startup Launcher v3.3.0
# Original 4-option launcher restored, with DevHub added as option 5.

AK_APP_DIR="${AK_APP_DIR:-$HOME/.termux-avid-kiya}"
AK_CONFIG="$AK_APP_DIR/config"
AK_AVID="$AK_APP_DIR/bin/avid"
AK_WTTR_LOCATION="36.46,52.86"
AK_USE_LOLCAT="1"
AK_AUTO_FISH_AFTER_TERMUX="1"
AK_AUTO_FISH_AFTER_UBUNTU="1"
AK_UBUNTU_DISTRO="ubuntu"
AK_STARTUP_MODE="ask"
AK_WEB_HOST="127.0.0.1"
AK_WEB_PORT="8765"
[ -f "$AK_CONFIG" ] && . "$AK_CONFIG"
export PATH="$AK_APP_DIR/bin:$PATH"
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"

ak_has(){ command -v "$1" >/dev/null 2>&1; }
ak_color(){ if [ "${AK_USE_LOLCAT:-1}" = "1" ] && ak_has lolcat; then lolcat; else cat; fi; }
ak_pause(){ printf '\nPress Enter to continue...'; read -r _; }
ak_weather(){ ak_has curl && curl -s --connect-timeout 8 "wttr.in/${AK_WTTR_LOCATION}" | head -7 || true; }
ak_prop(){ getprop "$1" 2>/dev/null | head -n 1; }
ak_ram(){ free -m 2>/dev/null | awk '/Mem:/ {print $3"MiB / "$2"MiB"}' || echo unknown; }

ak_menu_art(){ cat <<'ART'
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
5. 🚀 Avid Kiya DevHub - AI / Dev / Cyber / Web Panel
ART
}

ak_android_info(){
  local os device code rom kernel uptime cpu ram
  os="Android $(ak_prop ro.build.version.release)"; [ "$os" = "Android " ] && os="Android unknown"
  device="$(ak_prop ro.product.model)"; [ -z "$device" ] && device=unknown
  code="$(ak_prop ro.product.device)"; [ -z "$code" ] && code=unknown
  rom="$(ak_prop ro.build.id)"; [ -z "$rom" ] && rom=unknown
  kernel="$(uname -m) Linux $(uname -r)"; uptime="$(uptime -p 2>/dev/null | sed 's/^up //' || true)"
  cpu="$(ak_prop ro.hardware)"; [ -z "$cpu" ] && cpu="$(uname -m)"; ram="$(ak_ram)"
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

ak_termux_title(){ cat <<'EOF2'
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

ak_termux_banner(){ clear; ak_android_info | ak_color; echo; ak_termux_title | ak_color; ak_weather; date | ak_color; uname -a; export PS1='^^>>> '; [ "${AK_AUTO_FISH_AFTER_TERMUX:-1}" = "1" ] && ak_has fish && exec fish; }

ak_ubuntu_ok(){ ak_has proot-distro && proot-distro login "${AK_UBUNTU_DISTRO}" -- /bin/true >/dev/null 2>&1; }

ak_ubuntu_banner_and_shell(){
  ak_ubuntu_ok || { echo "Ubuntu is not ready. Choose option 3 first."; ak_pause; return; }
  proot-distro login "${AK_UBUNTU_DISTRO}" -- env AK_WTTR_LOCATION="$AK_WTTR_LOCATION" AK_AUTO_FISH_AFTER_UBUNTU="$AK_AUTO_FISH_AFTER_UBUNTU" bash -lc 'cat > /tmp/avid-ubuntu-rc.sh <<'"'"'RC_EOF'"'"'
export PATH="/root/.mimocode/bin:/root/.npm-global/bin:/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
[ -f /etc/profile.d/avid-kiya-path.sh ] && . /etc/profile.d/avid-kiya-path.sh
[ -f /root/.bashrc ] && . /root/.bashrc
c(){ if command -v lolcat >/dev/null 2>&1; then lolcat; else cat; fi; }
clear
cat <<'"'"'UBU'"'"' | c
       .--.
      |o_o |
      |:_/ |
     //   \ \        OS: Ubuntu/proot
    (|     | )       Host: Termux Android
   /'"'"'\_   _/`\       Kernel: Android/Linux kernel
   \___)=(___/       Shell: bash/fish
      .-"""-.        PATH: patched
     / .===. \       Tools: AI/Dev/Cyber ready
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
UBU
command -v curl >/dev/null 2>&1 && curl -s --connect-timeout 8 "wttr.in/${AK_WTTR_LOCATION:-36.46,52.86}" | head -7 || true
date | c
uname -a
if command -v mimo >/dev/null 2>&1; then echo "MiMo: $(command -v mimo)"; elif [ -x /root/.mimocode/bin/mimo ]; then echo "MiMo: /root/.mimocode/bin/mimo"; fi
if [ "${AK_AUTO_FISH_AFTER_UBUNTU:-1}" = "1" ] && command -v fish >/dev/null 2>&1; then exec fish -l; fi
export PS1=">>> "
RC_EOF
exec bash --rcfile /tmp/avid-ubuntu-rc.sh -i'
}

ak_installer(){
  if [ -x "$AK_AVID" ]; then "$AK_AVID" ubuntu-patch; else avid ubuntu-patch; fi
  ak_pause
}


ak_start_web_app(){
  if [ -x "$AK_AVID" ]; then "$AK_AVID" web-start; else avid web-start; fi
}

ak_start_mode_menu(){
  clear
  cat <<'MODE' | ak_color
╔════════════════════════════════════════════════════════════╗
║                  AvidKiya DevHub App                      ║
║        Mobile App / Classic CLI / Web / Shell             ║
╚════════════════════════════════════════════════════════════╝

1. 📱 App Mode - open mobile web app
2. 💻 CLI Mode - classic Termux/Ubuntu launcher
3. 🌐 Web Panel - start local web only
4. 🚀 Full DevHub terminal menu
5. 🐚 Normal shell
MODE
  printf '\nChoose mode [1-5]: '
  read -r m
  case "$m" in
    1) ak_start_web_app ;;
    2) ak_menu ;;
    3) ak_start_web_app ;;
    4) if [ -x "$AK_AVID" ]; then "$AK_AVID" menu; else avid menu; fi ;;
    5) clear ;;
    *) ak_menu ;;
  esac
}

ak_menu(){ clear; ak_menu_art | ak_color; printf '\nChoose option [1-5]: '; read -r c; case "$c" in 1) ak_termux_banner;; 2) ak_ubuntu_banner_and_shell;; 3) ak_installer;; 4) clear;; 5) if [ -x "$AK_AVID" ]; then "$AK_AVID" menu; else avid menu; fi;; *) echo Invalid;; esac; }

case "$-" in *i*) if [ -z "${AK_LAUNCHER_SHOWN:-}" ] && [ -n "${TERMUX_VERSION:-}${PREFIX:-}" ]; then export AK_LAUNCHER_SHOWN=1; case "${AK_STARTUP_MODE:-ask}" in app) ak_start_web_app;; cli) ak_menu;; web) ak_start_web_app;; shell) clear;; *) ak_start_mode_menu;; esac; fi;; esac
