#!/usr/bin/env bash
# Avid Kiya DevHub v3.0.0
# Termux + Ubuntu + AI + DevTools + Cybersecurity Lab
set +e

AK_APP_DIR="${AK_APP_DIR:-$HOME/.termux-avid-kiya}"
AK_CONFIG="$AK_APP_DIR/config"
AK_LOG_DIR="$AK_APP_DIR/logs"
AK_WEB_DIR="$AK_APP_DIR/web"
AK_AGENT_DIR="$AK_APP_DIR/agent"
AK_WEB_PID="$AK_APP_DIR/web.pid"
mkdir -p "$AK_LOG_DIR"

AK_WTTR_LOCATION="36.46,52.86"
AK_UBUNTU_DISTRO="ubuntu"
AK_USE_LOLCAT="1"
AK_WEB_HOST="127.0.0.1"
AK_WEB_PORT="8765"
AK_LANGUAGE="fa"
AK_MODELS_DIR="/root/.avid-devhub/models"
AK_LLAMA_SRC="/root/.avid-devhub/src/llama.cpp"
AK_LLAMA_PORT="8080"
AK_CLI_ANIMATION="1"
AK_CLI_THEME="mimo"
[ -f "$AK_CONFIG" ] && . "$AK_CONFIG"


# ---------- AvidKiya CLI UI ----------
C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'; C_CYAN=$'\033[38;5;51m'; C_PURPLE=$'\033[38;5;141m'; C_ORANGE=$'\033[38;5;208m'; C_GREEN=$'\033[38;5;82m'; C_GOLD=$'\033[38;5;220m'; C_RED=$'\033[38;5;203m'
ui_line(){ printf "%b\n" "${C_DIM}────────────────────────────────────────────────────────────${C_RESET}"; }
ui_splash(){
  [ "${AK_CLI_ANIMATION:-1}" = "1" ] || return 0
  clear
  cat <<'SPLASH'
 ✧        ✦              ✧                 ✦          ✧
        ✦       ✧              ✧       ✦

SPLASH
  printf "%b\n" "                 ${C_DIM}AvidKiya${C_RESET}"
  printf "%b\n" "            ${C_ORANGE}AVID${C_RESET} ${C_BOLD}DEVHUB${C_RESET} ${C_DIM}CODE${C_RESET}"
  printf "%b\n" ""
  printf "%b" "        ${C_DIM}loading modules"
  for _ in 1 2 3; do printf "%b" " ${C_GOLD}✦${C_RESET}"; sleep 0.08; done
  printf "\n"
  sleep 0.12
}
ui_banner(){ ui_banner; }


status_line(){
  printf "Termux:%s  Ubuntu:%s  MiMo:%s  Claude:%s  Gemini:%s\n" \
    "$(has pkg && echo OK || echo NO)" \
    "$(ubuntu_ok && echo OK || echo NO)" \
    "$(ubuntu_ok && ubuntu_exec 'command -v mimo >/dev/null 2>&1 || [ -x /root/.mimocode/bin/mimo ]' && echo OK || echo NO)" \
    "$(ubuntu_ok && ubuntu_exec 'command -v claude >/dev/null 2>&1' && echo OK || echo NO)" \
    "$(ubuntu_ok && ubuntu_exec 'command -v gemini >/dev/null 2>&1' && echo OK || echo NO)"
}

main_menu(){
ui_splash
while true; do clear; banner; status_line; ui_box_top; cat <<'MENU_EOF'

1. 🐧 Termux Environment
2. ☣️ Ubuntu Environment
3. ⚡ AvidKiya Agent
4. 🤖 AI CLI Tools
5. 🧠 Local AI Models
6. 🧰 Developer Tools
7. 🛡️ Cybersecurity / Authorized Pentest Lab
8. 🌐 Local Web Control Panel
9. 🩺 Health Check / Repair
10. ⚙️ Settings
11. 📜 Logs
12. 🚪 Exit
MENU_EOF
ui_menu_hint; ui_choice; read -r c
case "$c" in
 1) termux_menu;; 2) ubuntu_menu;; 3) agent_menu;; 4) ai_menu;; 5) local_ai_menu;; 6) dev_menu;; 7) cyber_menu;; 8) web_menu;; 9) health_menu;; 10) settings_menu;; 11) logs_menu;; 12|q|Q) break;; *) echo Invalid; pause;; esac
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
ui_menu_hint; ui_choice; read -r c
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
ui_menu_hint; ui_choice; read -r c
case "$c" in
1) proot-distro login "${AK_UBUNTU_DISTRO}";;
2) has proot-distro || pkg install -y proot-distro; proot-distro install "${AK_UBUNTU_DISTRO}"; pause;;
3) patch_ubuntu_full; pause;;
4) read -rp "Type REINSTALL to delete Ubuntu: " x; [ "$x" = REINSTALL ] && { proot-distro remove "${AK_UBUNTU_DISTRO}"; proot-distro install "${AK_UBUNTU_DISTRO}"; patch_ubuntu_full; }; pause;;
5) break;; esac; done; }

patch_ubuntu_full(){
ubuntu_ok || { echo "Ubuntu not ready. Install it first."; return 1; }
if ubuntu_exec '[ -f /root/.avid-devhub/base.ok ] && command -v fish >/dev/null 2>&1 && command -v curl >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1'; then
  log "Ubuntu base already patched. Skipping heavy base install."
  return 0
fi
ubuntu_run_logged 'export DEBIAN_FRONTEND=noninteractive; apt update; apt install -y bash fish curl wget git nano ca-certificates sudo ruby ruby-dev nodejs npm python3 python3-pip python3-venv python3-dev pipx build-essential gcc g++ make cmake pkg-config patch jq ripgrep fd-find sqlite3 htop tree unzip zip xz-utils procps util-linux coreutils findutils grep sed gawk iproute2 net-tools dnsutils openssl locales; locale-gen C.UTF-8 || true; gem install lolcat --no-document || true; mkdir -p /root/.config/fish/conf.d /root/.avid-devhub; cat > /root/.config/fish/conf.d/avid-kiya-path.fish <<"FISH_EOF"
set -gx PATH /root/.mimocode/bin /root/.npm-global/bin /root/.local/bin /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin $PATH
set -gx LANG C.UTF-8
set -gx LC_ALL C.UTF-8
FISH_EOF
cat > /etc/profile.d/avid-kiya-path.sh <<"SH_EOF"
export PATH="/root/.mimocode/bin:/root/.npm-global/bin:/root/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
SH_EOF
chmod +x /etc/profile.d/avid-kiya-path.sh; grep -q mimocode /root/.bashrc 2>/dev/null || echo "export PATH=\"/root/.mimocode/bin:\$PATH\"" >> /root/.bashrc; fish -lc '\''type -q omf; or curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish'\'' || true; fish -lc '\''omf install batman; or true; omf theme batman; or omf batman; or true'\'' || true; date > /root/.avid-devhub/base.ok'
}



local_ai_menu(){
while true; do clear; banner; cat <<'LOCAL_EOF'
🧠 Local AI Models - Offline / Private
Run GGUF models with llama.cpp inside Ubuntu. No API key needed.

1. Install/Build llama.cpp inside Ubuntu
2. Download recommended small model
3. Download model from custom URL
4. List local models
5. Run local model prompt
6. Start OpenAI-compatible local server
7. Stop local server
8. Configure Agent to use local model
9. Back
LOCAL_EOF
ui_menu_hint; ui_choice; read -r c
case "$c" in
1) local_install_llama; pause;;
2) local_download_recommended; pause;;
3) local_download_custom; pause;;
4) local_list_models; pause;;
5) local_run_prompt; pause;;
6) local_start_server; pause;;
7) local_stop_server; pause;;
8) local_agent_config; pause;;
9) break;; esac
done
}
local_ubuntu(){ ubuntu_ok || { echo "Ubuntu not ready. Install/Patch Ubuntu first."; return 1; }; }
local_install_llama(){
local_ubuntu || return 1
ubuntu_run_logged 'set -e; mkdir -p /root/.avid-devhub/src /root/.avid-devhub/models; apt update; apt install -y git build-essential cmake python3 curl wget ca-certificates; if [ ! -d /root/.avid-devhub/src/llama.cpp/.git ]; then git clone --depth 1 https://github.com/ggml-org/llama.cpp /root/.avid-devhub/src/llama.cpp; else cd /root/.avid-devhub/src/llama.cpp && git pull --ff-only || true; fi; cd /root/.avid-devhub/src/llama.cpp; if [ ! -x build/bin/llama-cli ] || [ ! -x build/bin/llama-server ]; then cmake -B build -DGGML_NATIVE=OFF -DGGML_OPENMP=OFF; cmake --build build --config Release -j$(nproc); else echo "llama.cpp already built. Skipping rebuild."; fi; ls -lh build/bin/llama-cli build/bin/llama-server 2>/dev/null || true'
}
local_download_recommended(){
local_ubuntu || return 1
cat <<'MODELS'
Recommended for Android/Termux phones:
1. TinyLlama 1.1B Chat Q4_K_M       ~670MB  fastest
2. Qwen2.5 0.5B Instruct Q4_K_M     ~400MB  very light
3. Qwen2.5 1.5B Instruct Q4_K_M     ~1GB    better quality
4. Phi-3 Mini 4K Instruct Q4        ~2.4GB  heavier
MODELS
read -rp "Choose model [1-4]: " m
case "$m" in
1) url='https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf'; file='tinyllama-1.1b-chat.Q4_K_M.gguf';;
2) url='https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf'; file='qwen2.5-0.5b-instruct-q4_k_m.gguf';;
3) url='https://huggingface.co/Qwen/Qwen2.5-1.5B-Instruct-GGUF/resolve/main/qwen2.5-1.5b-instruct-q4_k_m.gguf'; file='qwen2.5-1.5b-instruct-q4_k_m.gguf';;
4) url='https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf'; file='phi-3-mini-4k-instruct-q4.gguf';;
*) echo invalid; return;; esac
ubuntu_run_logged "mkdir -p /root/.avid-devhub/models; if [ -f /root/.avid-devhub/models/$file ]; then echo 'Model already exists. Skipping download.'; else wget -c -O /root/.avid-devhub/models/$file '$url'; fi; ls -lh /root/.avid-devhub/models/$file"
}
local_download_custom(){
local_ubuntu || return 1
read -rp "GGUF URL: " url
read -rp "File name (example model.gguf): " file
[ -z "$url" ] && return
[ -z "$file" ] && file="custom-model.gguf"
ubuntu_run_logged "mkdir -p /root/.avid-devhub/models; if [ -f /root/.avid-devhub/models/$file ]; then echo 'Model already exists. Skipping download.'; else wget -c -O /root/.avid-devhub/models/$file '$url'; fi; ls -lh /root/.avid-devhub/models/$file"
}
local_list_models(){ local_ubuntu || return 1; ubuntu_exec 'mkdir -p /root/.avid-devhub/models; ls -lh /root/.avid-devhub/models/*.gguf 2>/dev/null || echo "No GGUF models found."'; }
local_run_prompt(){
local_ubuntu || return 1
read -rp "Prompt: " prompt
ubuntu_exec "models=(/root/.avid-devhub/models/*.gguf); if [ ! -f \"\${models[0]}\" ]; then echo 'No GGUF model found.'; exit 1; fi; /root/.avid-devhub/src/llama.cpp/build/bin/llama-cli -m \"\${models[0]}\" -p \"$prompt\" -n 512"
}
local_start_server(){
local_ubuntu || return 1
ubuntu_run_logged "pkill -f llama-server || true; models=(/root/.avid-devhub/models/*.gguf); if [ ! -f \"\${models[0]}\" ]; then echo 'No GGUF model found.'; exit 1; fi; nohup /root/.avid-devhub/src/llama.cpp/build/bin/llama-server -m \"\${models[0]}\" --host 127.0.0.1 --port ${AK_LLAMA_PORT:-8080} > /root/.avid-devhub/llama-server.log 2>&1 & echo \$! > /root/.avid-devhub/llama-server.pid; echo 'Server: http://127.0.0.1:${AK_LLAMA_PORT:-8080}/v1/chat/completions'"
}
local_stop_server(){ local_ubuntu || return 1; ubuntu_exec 'pkill -f llama-server || true; rm -f /root/.avid-devhub/llama-server.pid; echo stopped'; }
local_agent_config(){
mkdir -p "$AK_APP_DIR/agent"
python "$AK_AGENT_DIR/avid_agent.py" init >/dev/null 2>&1 || true
python - <<AGENTPY
import json, pathlib
p=pathlib.Path('$AK_APP_DIR/agent/agent-config.json')
c=json.loads(p.read_text())
c['manager']='llama_local'; c['synthesizer']='llama_local'; c['workers']=['llama_local']
c.setdefault('providers',{})['llama_local']={'type':'openai_compatible','base_url':'http://127.0.0.1:${AK_LLAMA_PORT:-8080}/v1/chat/completions','model':'local-model','api_key_env':''}
p.write_text(json.dumps(c,indent=2,ensure_ascii=False))
print('Agent configured for llama_local. Start local server first.')
AGENTPY
}

agent_menu(){
while true; do clear; banner; cat <<'AGENT_EOF'
⚡ AvidKiya Agent
Safe multi-provider agent using official APIs, official CLIs and local models.

1. Init agent config
2. Show agent config path/content
3. Run agent prompt
4. Add OpenAI-compatible provider
5. Back
AGENT_EOF
ui_menu_hint; ui_choice; read -r c
case "$c" in
1) python "$AK_AGENT_DIR/avid_agent.py" init; pause;;
2) python "$AK_AGENT_DIR/avid_agent.py" config; pause;;
3) read -rp "Prompt: " p; python "$AK_AGENT_DIR/avid_agent.py" run "$p"; pause;;
4) read -rp "Name: " n; read -rp "Base URL: " u; read -rp "Model: " m; read -rp "API key env var: " e; python "$AK_AGENT_DIR/avid_agent.py" add-provider "$n" "$u" "$m" "$e"; pause;;
5) break;; esac
done
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
ui_menu_hint; ui_choice; read -r c
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
ui_menu_hint; ui_choice; read -r c
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
ui_menu_hint; ui_choice; read -r c
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
ui_menu_hint; ui_choice; read -r c
case "$c" in
1) confirm_auth || { pause; continue; }; read -rp "Target/IP/domain: " t; ubuntu_exec "nmap -sV --reason '$t'"; pause;;
2) read -rp "Domain: " d; ubuntu_exec "dig '$d' any +short"; pause;;
3) read -rp "URL: " u; ubuntu_exec "curl -I -L '$u'"; pause;;
4) confirm_auth || { pause; continue; }; read -rp "URL/domain: " u; ubuntu_exec "whatweb '$u'"; pause;;
5) break;; esac; done; }

web_menu(){
while true; do clear; banner; cat <<WEB_EOF
🌐 Local Web Control Panel / Mobile App
URL: http://${AK_WEB_HOST}:${AK_WEB_PORT}

1. Start mobile web app in background and open browser
2. Start web app in foreground
3. Stop background web app
4. Status
5. Back
WEB_EOF
ui_menu_hint; ui_choice; read -r c
case "$c" in
1) web_start_bg; pause;;
2) web_install_flask; cd "$AK_WEB_DIR" && AK_APP_DIR="$AK_APP_DIR" AK_WEB_HOST="$AK_WEB_HOST" AK_WEB_PORT="$AK_WEB_PORT" python app.py; pause;;
3) web_stop; pause;;
4) web_status; pause;;
5) break;; esac
done
}

health_once(){ clear; banner; echo "🩺 Health Check"; echo; status_line; echo; echo "Termux tools:"; for t in fish curl git ruby lolcat proot-distro python; do has "$t" && echo "[✓] $t" || echo "[ ] $t"; done; echo; echo "Ubuntu tools:"; cyber_health; }
health_menu(){ health_once; pause; }
settings_menu(){ ${EDITOR:-nano} "$AK_CONFIG"; }
logs_menu(){ clear; ls -lh "$AK_LOG_DIR"; echo; read -rp "Open log file name or Enter back: " f; [ -n "$f" ] && ${PAGER:-less} "$AK_LOG_DIR/$f"; }


# ---------- Arrow-key App UI v3.8 ----------
ui_key_select(){
  local title="$1"; shift
  local opts=("$@")
  local selected=0 key count=${#opts[@]}
  while true; do
    clear
    ui_banner
    printf "%b\n" "${C_DIM}╭──────────────────────────────────────────────────────────╮${C_RESET}"
    printf "%b\n" "${C_DIM}│${C_RESET} ${C_BOLD}${title}${C_RESET}"
    printf "%b\n" "${C_DIM}├──────────────────────────────────────────────────────────┤${C_RESET}"
    local i
    for i in "${!opts[@]}"; do
      if [ "$i" -eq "$selected" ]; then
        printf "%b\n" "${C_DIM}│${C_RESET} ${C_ORANGE}➜${C_RESET} ${C_BOLD}${opts[$i]}${C_RESET}"
      else
        printf "%b\n" "${C_DIM}│${C_RESET}   ${opts[$i]}"
      fi
    done
    printf "%b\n" "${C_DIM}╰──────────────────────────────────────────────────────────╯${C_RESET}"
    printf "%b\n" "${C_DIM}↑/↓ move   Enter select   q back   @AvidKiya${C_RESET}"
    IFS= read -rsn1 key
    if [[ $key == $'\x1b' ]]; then
      read -rsn2 key
      case "$key" in
        '[A') ((selected--)); [ "$selected" -lt 0 ] && selected=$((count-1)) ;;
        '[B') ((selected++)); [ "$selected" -ge "$count" ] && selected=0 ;;
      esac
    elif [[ $key == "" ]]; then
      return $((selected+1))
    elif [[ $key == "q" || $key == "Q" ]]; then
      return 255
    elif [[ $key =~ [0-9] ]]; then
      local n="$key"
      if [ "$n" -ge 1 ] 2>/dev/null && [ "$n" -le "$count" ] 2>/dev/null; then return "$n"; fi
    fi
  done
}

main_menu(){
  ui_splash
  while true; do
    ui_key_select "AvidKiya DevHub - Main" \
      "🐧 Termux Environment" \
      "☣️ Ubuntu Environment" \
      "⚡ AvidKiya Agent" \
      "🤖 AI CLI Tools" \
      "🧠 Local AI Models" \
      "🧰 Developer Tools" \
      "🛡️ Cybersecurity Lab" \
      "🌐 Local Web Control Panel" \
      "🩺 Health Check / Repair" \
      "⚙️ Settings" \
      "📜 Logs" \
      "🚪 Exit"
    case $? in
      1) termux_menu;; 2) ubuntu_menu;; 3) agent_menu;; 4) ai_menu;; 5) local_ai_menu;; 6) dev_menu;;
      7) cyber_menu;; 8) web_menu;; 9) health_menu;; 10) settings_menu;; 11) logs_menu;; 12|255) break;;
    esac
  done
}

termux_menu(){
  while true; do
    ui_key_select "Termux Environment" \
      "Update package lists only" \
      "Upgrade Termux packages - ask first" \
      "Install/Repair Fish + Oh My Fish + Batman" \
      "Install missing essential Termux packages" \
      "Setup Storage" \
      "Back"
    case $? in
      1) pkg update -y; pause;;
      2) read -rp "Run pkg upgrade? [y/N]: " a; [[ $a =~ ^[Yy] ]] && pkg upgrade -y; pause;;
      3) run_termux_pkg fish curl; fish -lc 'type -q omf; or curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish'; fish -lc 'omf install batman; or true; omf theme batman; or omf batman; or true'; pause;;
      4) run_termux_pkg termux-api python git ruby curl wget fish figlet screenfetch nano proot-distro nodejs openssh tmux jq ripgrep fd bat eza htop tree unzip zip; gem install lolcat --no-document || true; pause;;
      5) termux-setup-storage || true; pause;;
      6|255) break;;
    esac
  done
}

ubuntu_menu(){
  while true; do
    ui_key_select "Ubuntu Environment" \
      "Run Ubuntu Shell" \
      "Install Ubuntu container" \
      "Patch/Repair Ubuntu Base + PATH + Fish/Batman" \
      "Reinstall Ubuntu from zero - destructive" \
      "Back"
    case $? in
      1) proot-distro login "${AK_UBUNTU_DISTRO}";;
      2) has proot-distro || pkg install -y proot-distro; proot-distro install "${AK_UBUNTU_DISTRO}"; pause;;
      3) patch_ubuntu_full; pause;;
      4) read -rp "Type REINSTALL to delete Ubuntu: " x; [ "$x" = REINSTALL ] && { proot-distro remove "${AK_UBUNTU_DISTRO}"; proot-distro install "${AK_UBUNTU_DISTRO}"; patch_ubuntu_full; }; pause;;
      5|255) break;;
    esac
  done
}

agent_menu(){
  while true; do
    ui_key_select "AvidKiya Agent" \
      "Init agent config" \
      "Show agent config" \
      "Run agent prompt" \
      "Add OpenAI-compatible provider" \
      "Configure for local llama.cpp" \
      "Back"
    case $? in
      1) python "$AK_AGENT_DIR/avid_agent.py" init; pause;;
      2) python "$AK_AGENT_DIR/avid_agent.py" config; pause;;
      3) read -rp "Prompt: " p; python "$AK_AGENT_DIR/avid_agent.py" run "$p"; pause;;
      4) read -rp "Name: " n; read -rp "Base URL: " u; read -rp "Model: " m; read -rp "API key env var: " e; python "$AK_AGENT_DIR/avid_agent.py" add-provider "$n" "$u" "$m" "$e"; pause;;
      5) local_agent_config; pause;;
      6|255) break;;
    esac
  done
}

ai_menu(){
  while true; do
    ui_key_select "AI CLI Tools" \
      "Install/Repair MiMo Code" \
      "Run MiMo" \
      "Install Claude Code" \
      "Run Claude Code" \
      "Install Gemini CLI" \
      "Run Gemini CLI" \
      "Install Aider" \
      "Run Aider" \
      "Install All Recommended AI Tools" \
      "Back"
    case $? in
      1) install_mimo; pause;; 2) ubuntu_exec 'cd /root; source /root/.bashrc 2>/dev/null || true; command -v mimo >/dev/null 2>&1 && exec mimo || exec /root/.mimocode/bin/mimo';;
      3) install_claude; pause;; 4) ubuntu_exec 'claude';;
      5) install_gemini; pause;; 6) ubuntu_exec 'gemini';;
      7) ubuntu_run_logged 'apt install -y pipx python3-venv; pipx ensurepath; pipx install aider-chat || pip install -U aider-chat'; pause;;
      8) ubuntu_exec 'aider';;
      9) install_mimo; install_claude; install_gemini; ubuntu_run_logged 'apt install -y pipx python3-venv; pipx ensurepath; pipx install aider-chat || pip install -U aider-chat'; pause;;
      10|255) break;;
    esac
  done
}

local_ai_menu(){
  while true; do
    ui_key_select "Local AI Models - Offline / Private" \
      "Install/Build llama.cpp inside Ubuntu" \
      "Download recommended small model" \
      "Download model from custom URL" \
      "List local models" \
      "Run local model prompt" \
      "Start OpenAI-compatible local server" \
      "Stop local server" \
      "Configure Agent to use local model" \
      "Back"
    case $? in
      1) local_install_llama; pause;; 2) local_download_recommended; pause;; 3) local_download_custom; pause;; 4) local_list_models; pause;;
      5) local_run_prompt; pause;; 6) local_start_server; pause;; 7) local_stop_server; pause;; 8) local_agent_config; pause;; 9|255) break;;
    esac
  done
}

dev_menu(){
  while true; do
    ui_key_select "Developer Tools" \
      "Install Node.js/npm tools" \
      "Install Python/pipx tools" \
      "Install Git/GitHub tools" \
      "Install Terminal power tools" \
      "Install All Dev Tools" \
      "Back"
    case $? in
      1) ubuntu_run_logged 'apt install -y nodejs npm; npm install -g npm@latest pnpm yarn typescript ts-node nodemon'; pause;;
      2) ubuntu_run_logged 'apt install -y python3 python3-pip python3-venv pipx; pipx ensurepath; pipx install poetry || true'; pause;;
      3) ubuntu_run_logged 'apt install -y git gh || apt install -y git'; pause;;
      4) ubuntu_run_logged 'apt install -y tmux htop tree jq ripgrep fd-find bat fzf screenfetch figlet ruby; gem install lolcat --no-document || true'; pause;;
      5) ubuntu_run_logged 'apt install -y nodejs npm python3 python3-pip python3-venv pipx git tmux htop tree jq ripgrep fd-find bat fzf screenfetch figlet ruby build-essential'; pause;;
      6|255) break;;
    esac
  done
}

cyber_menu(){
  while true; do
    ui_key_select "Cybersecurity / Authorized Pentest Lab" \
      "Install Essential Security Pack" \
      "Install Recon & Network Mapping Pack" \
      "Install Web Security Testing Pack" \
      "Install Password/Hash Auditing Pack" \
      "Install CTF + Pwn Pack" \
      "Install Forensics + Steganography Pack" \
      "Install Reverse Engineering Pack" \
      "Install Advanced Optional Pack" \
      "Install FULL Cybersecurity Pack" \
      "Security Tools Health Check" \
      "Authorized Run Helpers" \
      "Back"
    case $? in
      1) cyber_essential; pause;; 2) cyber_recon; pause;; 3) cyber_web; pause;; 4) cyber_hash; pause;; 5) cyber_ctf; pause;; 6) cyber_forensics; pause;;
      7) cyber_reverse; pause;; 8) cyber_advanced; pause;; 9) cyber_full; pause;; 10) cyber_health; pause;; 11) cyber_helpers;; 12|255) break;;
    esac
  done
}

web_menu(){
  while true; do
    ui_key_select "Local Web Control Panel / Mobile App" \
      "Start mobile web app in background and open browser" \
      "Start web app in foreground" \
      "Stop background web app" \
      "Web app status" \
      "Back"
    case $? in
      1) web_start_bg; pause;;
      2) web_install_flask; cd "$AK_WEB_DIR" && AK_APP_DIR="$AK_APP_DIR" AK_WEB_HOST="$AK_WEB_HOST" AK_WEB_PORT="$AK_WEB_PORT" python app.py; pause;;
      3) web_stop; pause;; 4) web_status; pause;; 5|255) break;;
    esac
  done
}

case "${1:-menu}" in
 menu) main_menu;; agent) agent_menu;; local-ai) local_ai_menu;; web) web_menu;; web-start) web_start_bg;; web-stop) web_stop;; web-status) web_status;; health) health_menu;; health-once) health_once;; security|cyber) cyber_menu;; ai) ai_menu;; ubuntu) ubuntu_menu;; termux) termux_menu;;
 ubuntu-patch) patch_ubuntu_full;; local-ai-install) local_install_llama;; local-ai-server) local_start_server;; agent-run) shift; python "$AK_AGENT_DIR/avid_agent.py" run "$@";;
 ai-mimo) install_mimo;; ai-claude) install_claude;; ai-gemini) install_gemini;; ai-aider) ubuntu_run_logged 'apt install -y pipx python3-venv; pipx ensurepath; pipx install aider-chat || pip install -U aider-chat';; ai-all) install_mimo; install_claude; install_gemini; ubuntu_run_logged 'apt install -y pipx python3-venv; pipx ensurepath; pipx install aider-chat || pip install -U aider-chat';;
 dev-all) ubuntu_run_logged 'apt install -y nodejs npm python3 python3-pip python3-venv pipx git tmux htop tree jq ripgrep fd-find bat fzf screenfetch figlet ruby build-essential; npm install -g npm@latest pnpm yarn typescript ts-node nodemon || true';;
 cyber-essential) cyber_essential;; cyber-recon) cyber_recon;; cyber-web) cyber_web;; cyber-hash) cyber_hash;; cyber-ctf) cyber_ctf;; cyber-forensics) cyber_forensics;; cyber-reverse) cyber_reverse;; cyber-full) cyber_full;;
 *) main_menu;; esac
