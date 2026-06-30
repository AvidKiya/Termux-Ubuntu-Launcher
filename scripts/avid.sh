#!/usr/bin/env bash
# Avid Kiya DevHub v3.0.0
# Termux + Ubuntu + AI + DevTools + Cybersecurity Lab
set +e

AK_APP_DIR="${AK_APP_DIR:-$HOME/.termux-avid-kiya}"
AK_CONFIG="$AK_APP_DIR/config"
AK_LOG_DIR="$AK_APP_DIR/logs"
AK_WEB_DIR="$AK_APP_DIR/web"
mkdir -p "$AK_LOG_DIR"

AK_WTTR_LOCATION="36.46,52.86"
AK_UBUNTU_DISTRO="ubuntu"
AK_USE_LOLCAT="1"
AK_WEB_HOST="127.0.0.1"
AK_WEB_PORT="8765"
AK_LANGUAGE="fa"
[ -f "$AK_CONFIG" ] && . "$AK_CONFIG"

has(){ command -v "$1" >/dev/null 2>&1; }
color(){ if [ "${AK_USE_LOLCAT:-1}" = "1" ] && has lolcat; then lolcat; else cat; fi; }
pause(){ printf '\nPress Enter to continue...'; read -r _; }
log(){ printf '[%s] %s\n' "$(date '+%F %T')" "$*" | tee -a "$AK_LOG_DIR/avid.log"; }
confirm_auth(){ echo; echo "Authorized testing only. فقط روی سیستم‌های خودتان، لَب، CTF یا هدف دارای مجوز استفاده کنید."; printf "Type AUTHORIZED to continue: "; read -r x; [ "$x" = "AUTHORIZED" ]; }

run_termux_pkg(){ log "TERMUX: pkg install $*"; pkg install -y "$@" 2>&1 | tee -a "$AK_LOG_DIR/termux-tools.log"; }
ubuntu_ok(){ has proot-distro && proot-distro login "${AK_UBUNTU_DISTRO}" -- /bin/true >/dev/null 2>&1; }
ubuntu_exec(){ proot-distro login "${AK_UBUNTU_DISTRO}" -- bash -lc "$*"; }
ubuntu_run_logged(){ log "UBUNTU: $*"; proot-distro login "${AK_UBUNTU_DISTRO}" -- bash -lc "$*" 2>&1 | tee -a "$AK_LOG_DIR/ubuntu-tools.log"; }

banner(){ cat <<'BANNER_EOF' | color
╔════════════════════════════════════════════════════════════╗
║                    Avid Kiya DevHub                       ║
║       Termux + Ubuntu + AI + Dev + Cybersecurity Lab      ║
╚════════════════════════════════════════════════════════════╝
BANNER_EOF
}

status_line(){
  printf "Termux:%s  Ubuntu:%s  MiMo:%s  Claude:%s  Gemini:%s\n" \
    "$(has pkg && echo OK || echo NO)" \
    "$(ubuntu_ok && echo OK || echo NO)" \
    "$(ubuntu_ok && ubuntu_exec 'command -v mimo >/dev/null 2>&1 || [ -x /root/.mimocode/bin/mimo ]' && echo OK || echo NO)" \
    "$(ubuntu_ok && ubuntu_exec 'command -v claude >/dev/null 2>&1' && echo OK || echo NO)" \
    "$(ubuntu_ok && ubuntu_exec 'command -v gemini >/dev/null 2>&1' && echo OK || echo NO)"
}

main_menu(){
while true; do clear; banner; status_line; cat <<'MENU_EOF'

1. 🐧 Termux Environment
2. ☣️ Ubuntu Environment
3. 🤖 AI Coding Tools
4. 🧰 Developer Tools
5. 🛡️ Cybersecurity / Authorized Pentest Lab
6. 🌐 Local Web Control Panel
7. 🩺 Health Check / Repair
8. ⚙️ Settings
9. 📜 Logs
10. 🚪 Exit
MENU_EOF
printf "\nChoose option: "; read -r c
case "$c" in
 1) termux_menu;; 2) ubuntu_menu;; 3) ai_menu;; 4) dev_menu;; 5) cyber_menu;; 6) web_menu;; 7) health_menu;; 8) settings_menu;; 9) logs_menu;; 10|q|Q) break;; *) echo Invalid; pause;; esac
done
}

termux_menu(){ while true; do clear; banner; cat <<'MENU_EOF'
🐧 Termux Environment
1. Update/Upgrade Termux
2. Install/Repair Fish + Oh My Fish + Batman
3. Install Essential Termux Packages
4. Setup Storage
5. Back
MENU_EOF
read -rp "Choose: " c
case "$c" in
1) pkg update -y && pkg upgrade -y; pause;;
2) run_termux_pkg fish curl; fish -lc 'type -q omf; or curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish'; fish -lc 'omf install batman; or true; omf theme batman; or omf batman; or true'; pause;;
3) run_termux_pkg termux-api python git ruby curl wget fish figlet screenfetch nano proot-distro nodejs openssh tmux jq ripgrep fd bat eza htop tree unzip zip; gem install lolcat --no-document || true; pause;;
4) termux-setup-storage || true; pause;;
5) break;; esac; done; }

ubuntu_menu(){ while true; do clear; banner; cat <<'MENU_EOF'
☣️ Ubuntu Environment
1. Run Ubuntu Shell
2. Install Ubuntu
3. Patch/Repair Ubuntu Base + PATH + Fish/Batman
4. Reinstall Ubuntu from zero
5. Back
MENU_EOF
read -rp "Choose: " c
case "$c" in
1) proot-distro login "${AK_UBUNTU_DISTRO}";;
2) has proot-distro || pkg install -y proot-distro; proot-distro install "${AK_UBUNTU_DISTRO}"; pause;;
3) patch_ubuntu_full; pause;;
4) read -rp "Type REINSTALL to delete Ubuntu: " x; [ "$x" = REINSTALL ] && { proot-distro remove "${AK_UBUNTU_DISTRO}"; proot-distro install "${AK_UBUNTU_DISTRO}"; patch_ubuntu_full; }; pause;;
5) break;; esac; done; }

patch_ubuntu_full(){
ubuntu_ok || { echo "Ubuntu not ready. Install it first."; return 1; }
ubuntu_run_logged 'export DEBIAN_FRONTEND=noninteractive; apt update; apt install -y bash fish curl wget git nano ca-certificates sudo ruby ruby-dev nodejs npm python3 python3-pip python3-venv python3-dev pipx build-essential gcc g++ make cmake pkg-config patch jq ripgrep fd-find sqlite3 htop tree unzip zip xz-utils procps util-linux coreutils findutils grep sed gawk iproute2 net-tools dnsutils openssl locales; locale-gen C.UTF-8 || true; gem install lolcat --no-document || true; mkdir -p /root/.config/fish/conf.d; cat > /root/.config/fish/conf.d/avid-kiya-path.fish <<"FISH_EOF"
set -gx PATH /root/.mimocode/bin /root/.npm-global/bin /root/.local/bin /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin $PATH
set -gx LANG C.UTF-8
set -gx LC_ALL C.UTF-8
FISH_EOF
cat > /etc/profile.d/avid-kiya-path.sh <<"SH_EOF"
export PATH="/root/.mimocode/bin:/root/.npm-global/bin:/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
SH_EOF
chmod +x /etc/profile.d/avid-kiya-path.sh; grep -q mimocode /root/.bashrc 2>/dev/null || echo "export PATH=\"/root/.mimocode/bin:\$PATH\"" >> /root/.bashrc; fish -lc '\''type -q omf; or curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish'\'' || true; fish -lc '\''omf install batman; or true; omf theme batman; or omf batman; or true'\'' || true'
}

ai_menu(){ while true; do clear; banner; cat <<'MENU_EOF'
🤖 AI Coding Tools
1. Install/Repair MiMo Code
2. Run MiMo
3. Install Claude Code
4. Run Claude Code
5. Install Gemini CLI
6. Run Gemini CLI
7. Install Aider
8. Run Aider
9. Install All Recommended AI Tools
10. Back
MENU_EOF
read -rp "Choose: " c
case "$c" in
1) install_mimo; pause;; 2) ubuntu_exec 'cd /root; source /root/.bashrc 2>/dev/null || true; command -v mimo >/dev/null 2>&1 && exec mimo || exec /root/.mimocode/bin/mimo';;
3) install_claude; pause;; 4) ubuntu_exec 'claude';;
5) install_gemini; pause;; 6) ubuntu_exec 'gemini';;
7) ubuntu_run_logged 'apt install -y pipx python3-venv; pipx ensurepath; pipx install aider-chat || pip install -U aider-chat'; pause;;
8) ubuntu_exec 'aider';;
9) install_mimo; install_claude; install_gemini; ubuntu_run_logged 'apt install -y pipx python3-venv; pipx ensurepath; pipx install aider-chat || pip install -U aider-chat'; pause;;
10) break;; esac; done; }

install_mimo(){ patch_ubuntu_full; ubuntu_run_logged 'export PATH="/root/.mimocode/bin:/usr/local/bin:/usr/bin:/bin:$PATH"; curl -fsSL https://mimo.xiaomi.com/install | bash || true; npm install -g @mimo-ai/cli || true; grep -q mimocode /root/.bashrc || echo "export PATH=\"/root/.mimocode/bin:\$PATH\"" >> /root/.bashrc; [ -x /root/.mimocode/bin/mimo ] && ln -sf /root/.mimocode/bin/mimo /usr/local/bin/mimo || true; source /root/.bashrc 2>/dev/null || true; command -v mimo || true'; }
install_claude(){ patch_ubuntu_full; ubuntu_run_logged 'npm install -g @anthropic-ai/claude-code || true; command -v claude || true'; }
install_gemini(){ patch_ubuntu_full; ubuntu_run_logged 'npm install -g @google/gemini-cli || true; command -v gemini || true'; }

dev_menu(){ while true; do clear; banner; cat <<'MENU_EOF'
🧰 Developer Tools
1. Install Node.js/npm tools
2. Install Python/pipx tools
3. Install Git/GitHub tools
4. Install Terminal power tools
5. Install All Dev Tools
6. Back
MENU_EOF
read -rp "Choose: " c
case "$c" in
1) ubuntu_run_logged 'apt install -y nodejs npm; npm install -g npm@latest pnpm yarn typescript ts-node nodemon'; pause;;
2) ubuntu_run_logged 'apt install -y python3 python3-pip python3-venv pipx; pipx ensurepath; pipx install poetry || true'; pause;;
3) ubuntu_run_logged 'apt install -y git gh || apt install -y git'; pause;;
4) ubuntu_run_logged 'apt install -y tmux htop tree jq ripgrep fd-find bat fzf screenfetch figlet ruby; gem install lolcat --no-document || true'; pause;;
5) ubuntu_run_logged 'apt install -y nodejs npm python3 python3-pip python3-venv pipx git tmux htop tree jq ripgrep fd-find bat fzf screenfetch figlet ruby build-essential'; pause;;
6) break;; esac; done; }

cyber_menu(){ while true; do clear; banner; cat <<'MENU_EOF'
🛡️ Cybersecurity / Authorized Pentest Lab
For CTF, university labs, personal systems, and authorized tests only.

1. Install Essential Security Pack
2. Install Recon & Network Mapping Pack
3. Install Web Security Testing Pack
4. Install Password/Hash Auditing Pack
5. Install CTF + Pwn Pack
6. Install Forensics + Steganography Pack
7. Install Reverse Engineering Pack
8. Install Advanced Optional Pack (Hydra/Metasploit if available)
9. Install FULL Cybersecurity Pack
10. Security Tools Health Check
11. Authorized Run Helpers
12. Back
MENU_EOF
read -rp "Choose: " c
case "$c" in
1) cyber_essential; pause;; 2) cyber_recon; pause;; 3) cyber_web; pause;; 4) cyber_hash; pause;; 5) cyber_ctf; pause;; 6) cyber_forensics; pause;; 7) cyber_reverse; pause;; 8) cyber_advanced; pause;; 9) cyber_full; pause;; 10) cyber_health; pause;; 11) cyber_helpers;; 12) break;; esac; done; }

cyber_essential(){ patch_ubuntu_full; ubuntu_run_logged 'apt install -y nmap netcat-openbsd whois dnsutils traceroute curl wget jq python3 git whatweb'; }
cyber_recon(){ patch_ubuntu_full; ubuntu_run_logged 'apt install -y nmap netcat-openbsd whois dnsutils traceroute iproute2 net-tools whatweb wafw00f curl wget jq; pipx install rustscan || true'; }
cyber_web(){ patch_ubuntu_full; ubuntu_run_logged 'apt install -y nikto sqlmap whatweb wafw00f gobuster ffuf httpie python3-pip git; pipx install dirsearch || pip install -U dirsearch || true'; }
cyber_hash(){ patch_ubuntu_full; ubuntu_run_logged 'apt install -y john hashcat hashid wordlists crunch || apt install -y john hashid crunch'; }
cyber_ctf(){ patch_ubuntu_full; ubuntu_run_logged 'apt install -y gdb gdbserver radare2 binutils strace ltrace file xxd python3-pip python3-venv; pipx install pwntools || pip install -U pwntools; pipx install checksec || true'; }
cyber_forensics(){ patch_ubuntu_full; ubuntu_run_logged 'apt install -y binwalk exiftool file foremost steghide imagemagick xxd ruby; gem install zsteg || true'; }
cyber_reverse(){ patch_ubuntu_full; ubuntu_run_logged 'apt install -y gdb gdbserver radare2 binutils strace ltrace file xxd patchelf python3-pip; pipx install checksec || true'; }
cyber_advanced(){ patch_ubuntu_full; echo "Advanced tools are optional and lab-only."; confirm_auth || return; ubuntu_run_logged 'apt install -y hydra metasploit-framework || apt install -y hydra || true'; }
cyber_full(){ cyber_essential; cyber_recon; cyber_web; cyber_hash; cyber_ctf; cyber_forensics; cyber_reverse; }

cyber_health(){ ubuntu_ok || { echo Ubuntu not ready; return; }; ubuntu_exec 'for t in nmap whatweb nikto sqlmap gobuster ffuf john hashid gdb radare2 binwalk exiftool steghide hydra; do if command -v $t >/dev/null 2>&1; then echo "[✓] $t: $(command -v $t)"; else echo "[ ] $t: missing"; fi; done'; }

cyber_helpers(){ while true; do clear; cat <<'MENU_EOF'
Authorized Run Helpers
1. nmap helper
2. DNS lookup helper
3. HTTP headers helper
4. WhatWeb helper
5. Back
MENU_EOF
read -rp "Choose: " c
case "$c" in
1) confirm_auth || { pause; continue; }; read -rp "Target/IP/domain: " t; ubuntu_exec "nmap -sV --reason '$t'"; pause;;
2) read -rp "Domain: " d; ubuntu_exec "dig '$d' any +short"; pause;;
3) read -rp "URL: " u; ubuntu_exec "curl -I -L '$u'"; pause;;
4) confirm_auth || { pause; continue; }; read -rp "URL/domain: " u; ubuntu_exec "whatweb '$u'"; pause;;
5) break;; esac; done; }

web_menu(){ clear; banner; cat <<WEB_EOF
🌐 Local Web Control Panel
URL: http://${AK_WEB_HOST}:${AK_WEB_PORT}
WEB_EOF
if [ ! -f "$AK_WEB_DIR/app.py" ]; then echo "Web files not found: $AK_WEB_DIR"; pause; return; fi
if ! has python; then pkg install -y python; fi
python -m pip install --user flask >/dev/null 2>&1 || pip install flask >/dev/null 2>&1 || true
cd "$AK_WEB_DIR" && AK_APP_DIR="$AK_APP_DIR" AK_WEB_HOST="$AK_WEB_HOST" AK_WEB_PORT="$AK_WEB_PORT" python app.py
}

health_menu(){ clear; banner; echo "🩺 Health Check"; echo; status_line; echo; echo "Termux tools:"; for t in fish curl git ruby lolcat proot-distro python; do has "$t" && echo "[✓] $t" || echo "[ ] $t"; done; echo; echo "Ubuntu tools:"; cyber_health; pause; }
settings_menu(){ ${EDITOR:-nano} "$AK_CONFIG"; }
logs_menu(){ clear; ls -lh "$AK_LOG_DIR"; echo; read -rp "Open log file name or Enter back: " f; [ -n "$f" ] && ${PAGER:-less} "$AK_LOG_DIR/$f"; }

case "${1:-menu}" in
 menu) main_menu;; web) web_menu;; health) health_menu;; security|cyber) cyber_menu;; ai) ai_menu;; ubuntu) ubuntu_menu;; termux) termux_menu;; *) main_menu;; esac
