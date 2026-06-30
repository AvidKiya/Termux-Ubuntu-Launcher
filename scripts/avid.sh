#!/usr/bin/env bash
# AvidKiya DevHub v3.8.1
# Termux + Ubuntu + AI + Local AI + Dev + Cybersecurity Lab
set +e

AK_APP_DIR="${AK_APP_DIR:-$HOME/.termux-avid-kiya}"
AK_CONFIG="$AK_APP_DIR/config"
AK_LOG_DIR="$AK_APP_DIR/logs"
AK_WEB_DIR="$AK_APP_DIR/web"
AK_AGENT_DIR="$AK_APP_DIR/agent"
AK_WEB_PID="$AK_APP_DIR/web.pid"
mkdir -p "$AK_LOG_DIR" "$AK_AGENT_DIR"

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

# ---------- Base helpers ----------
has(){ command -v "$1" >/dev/null 2>&1; }
pause(){ printf '\nPress Enter to continue...'; read -r _; }
log(){ printf '[%s] %s\n' "$(date '+%F %T')" "$*" | tee -a "$AK_LOG_DIR/avid.log"; }
confirm_auth(){ echo; echo "Authorized testing only. فقط روی سیستم‌های خودتان، لَب، CTF یا هدف دارای مجوز استفاده کنید."; printf "Type AUTHORIZED to continue: "; read -r x; [ "$x" = "AUTHORIZED" ]; }
run_termux_pkg(){ log "TERMUX: pkg install $*"; pkg install -y "$@" 2>&1 | tee -a "$AK_LOG_DIR/termux-tools.log"; }
ubuntu_ok(){ has proot-distro && proot-distro login "${AK_UBUNTU_DISTRO}" -- /bin/true >/dev/null 2>&1; }
ubuntu_exec(){ proot-distro login "${AK_UBUNTU_DISTRO}" -- bash -lc "$*"; }
ubuntu_run_logged(){ log "UBUNTU: $*"; proot-distro login "${AK_UBUNTU_DISTRO}" -- bash -lc "$*" 2>&1 | tee -a "$AK_LOG_DIR/ubuntu-tools.log"; }

ubuntu_apt_missing(){
  ubuntu_ok || { echo "Ubuntu not ready. Install it first."; return 1; }
  local missing
  missing="$(proot-distro login "${AK_UBUNTU_DISTRO}" -- bash -s -- "$@" <<'UBU'
for p in "$@"; do dpkg -s "$p" >/dev/null 2>&1 || printf '%s ' "$p"; done
UBU
)"
  if [ -z "$(printf '%s' "$missing" | tr -d '[:space:]')" ]; then
    echo "✅ All requested Ubuntu packages are already installed. No internet used."
    log "UBUNTU: all packages already installed: $*"
    return 0
  fi
  log "UBUNTU install missing packages:$missing"
  echo "📦 Installing only missing packages:$missing"
  proot-distro login "${AK_UBUNTU_DISTRO}" -- bash -lc "export DEBIAN_FRONTEND=noninteractive; apt-get install -y --no-install-recommends $missing" >> "$AK_LOG_DIR/ubuntu-tools.log" 2>&1
  local code=$?
  [ $code -eq 0 ] && echo "✅ Installed missing packages." || echo "⚠️ Some packages failed. Check logs: $AK_LOG_DIR/ubuntu-tools.log"
  return $code
}
ubuntu_pipx_install(){ ubuntu_ok || return 1; local tool="$1"; shift; ubuntu_exec "command -v '$tool' >/dev/null 2>&1" && { echo "✅ $tool already installed. Skipping."; return 0; }; ubuntu_run_logged "$*"; }

# ---------- UI ----------
C_RESET=$'\033[0m'; C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'; C_CYAN=$'\033[38;5;51m'; C_PURPLE=$'\033[38;5;141m'; C_ORANGE=$'\033[38;5;208m'; C_GREEN=$'\033[38;5;82m'; C_GOLD=$'\033[38;5;220m'; C_RED=$'\033[38;5;203m'
ui_splash(){
  [ "${AK_CLI_ANIMATION:-1}" = "1" ] || return 0
  clear
  printf "%b\n" "${C_DIM}✧        ✦              ✧                 ✦          ✧${C_RESET}"
  printf "%b\n" "${C_DIM}       ✦       ✧              ✧       ✦${C_RESET}"
  printf "\n"
  printf "%b\n" "                 ${C_DIM}AvidKiya${C_RESET}"
  printf "%b\n" "            ${C_ORANGE}AVID${C_RESET} ${C_BOLD}DEVHUB${C_RESET} ${C_DIM}CODE${C_RESET}"
  printf "\n%b" "        ${C_DIM}loading modules${C_RESET}"
  for _ in 1 2 3; do printf "%b" " ${C_GOLD}✦${C_RESET}"; sleep 0.06; done
  printf "\n"; sleep 0.08
}
ui_banner(){
  printf "%b\n" "${C_DIM}✧        ✦              ✧                 ✦          ✧${C_RESET}"
  printf "\n"
  printf "%b\n" "                 ${C_DIM}AvidKiya${C_RESET}"
  printf "%b\n" "            ${C_ORANGE}AVID${C_RESET} ${C_BOLD}DEVHUB${C_RESET} ${C_DIM}CODE${C_RESET}"
  printf "\n"
  printf "%b\n" "${C_DIM}╭──────────────────────────────────────────────────────────╮${C_RESET}"
  printf "%b\n" "${C_DIM}│${C_RESET} ${C_CYAN}Termux${C_RESET} + ${C_PURPLE}Ubuntu${C_RESET} + ${C_ORANGE}AI Agent${C_RESET} + ${C_GREEN}Dev${C_RESET} + ${C_GOLD}Cyber Lab${C_RESET} ${C_DIM}│${C_RESET}"
  printf "%b\n" "${C_DIM}╰──────────────────────────────────────────────────────────╯${C_RESET}"
}
banner(){ ui_banner; }
ui_hint(){ printf "%b\n" "${C_DIM}↑/↓ move   Enter select   q back   numbers quick select   @AvidKiya${C_RESET}"; }
ui_key_select(){
  local title="$1"; shift
  local opts=("$@") selected=0 key count=${#opts[@]}
  while true; do
    clear; ui_banner
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
    ui_hint
    IFS= read -rsn1 key
    if [[ $key == $'\x1b' ]]; then
      read -rsn2 key
      case "$key" in
        '[A') ((selected--)); [ "$selected" -lt 0 ] && selected=$((count-1));;
        '[B') ((selected++)); [ "$selected" -ge "$count" ] && selected=0;;
      esac
    elif [[ $key == "" ]]; then
      return $((selected+1))
    elif [[ $key == q || $key == Q ]]; then
      return 255
    elif [[ $key =~ [0-9] ]]; then
      local n="$key"
      [ "$n" -ge 1 ] 2>/dev/null && [ "$n" -le "$count" ] 2>/dev/null && return "$n"
    fi
  done
}
status_line(){
  printf "%b\n" "${C_DIM}Termux:${C_RESET}$(has pkg && echo OK || echo NO)  ${C_DIM}Ubuntu:${C_RESET}$(ubuntu_ok && echo OK || echo NO)  ${C_DIM}MiMo:${C_RESET}$(ubuntu_ok && ubuntu_exec 'command -v mimo >/dev/null 2>&1 || [ -x /root/.mimocode/bin/mimo ]' && echo OK || echo NO)  ${C_DIM}Claude:${C_RESET}$(ubuntu_ok && ubuntu_exec 'command -v claude >/dev/null 2>&1' && echo OK || echo NO)  ${C_DIM}Gemini:${C_RESET}$(ubuntu_ok && ubuntu_exec 'command -v gemini >/dev/null 2>&1' && echo OK || echo NO)"
}

# ---------- Web app ----------
web_install_flask(){
  python - <<'PY' >/dev/null 2>&1
import flask
PY
  if [ $? -ne 0 ]; then
    log "Installing Flask for local web app..."
    python -m pip install --user flask >/dev/null 2>&1 || pip install flask >/dev/null 2>&1 || true
  fi
}
web_start_bg(){
  if [ ! -f "$AK_WEB_DIR/app.py" ]; then echo "Web files not found: $AK_WEB_DIR"; return 1; fi
  if [ -f "$AK_WEB_PID" ] && kill -0 "$(cat "$AK_WEB_PID")" >/dev/null 2>&1; then
    echo "Web app already running: http://${AK_WEB_HOST}:${AK_WEB_PORT}"
  else
    web_install_flask
    log "Starting web app in background..."
    (cd "$AK_WEB_DIR" && AK_APP_DIR="$AK_APP_DIR" AK_WEB_HOST="$AK_WEB_HOST" AK_WEB_PORT="$AK_WEB_PORT" nohup python app.py >> "$AK_LOG_DIR/web.log" 2>&1 & echo $! > "$AK_WEB_PID")
    sleep 1
    echo "Web app: http://${AK_WEB_HOST}:${AK_WEB_PORT}"
  fi
  if has termux-open-url; then termux-open-url "http://${AK_WEB_HOST}:${AK_WEB_PORT}" >/dev/null 2>&1 || true; fi
}
web_stop(){
  if [ -f "$AK_WEB_PID" ] && kill -0 "$(cat "$AK_WEB_PID")" >/dev/null 2>&1; then kill "$(cat "$AK_WEB_PID")" || true; rm -f "$AK_WEB_PID"; echo "Web app stopped."; else echo "Web app is not running."; fi
}
web_status(){ if [ -f "$AK_WEB_PID" ] && kill -0 "$(cat "$AK_WEB_PID")" >/dev/null 2>&1; then echo "running: http://${AK_WEB_HOST}:${AK_WEB_PORT} pid=$(cat "$AK_WEB_PID")"; else echo "stopped"; fi; }


# ---------- Android-like App Mode ----------
app_open(){
  web_start_bg || return 1
  local url="http://${AK_WEB_HOST}:${AK_WEB_PORT}/?mode=app"
  echo "Opening AvidKiya DevHub App: $url"
  if has termux-open-url; then
    termux-open-url "$url" >/dev/null 2>&1 || true
  else
    echo "termux-open-url not found. Open manually: $url"
  fi
}
app_install_shortcuts(){
  mkdir -p "$HOME/.shortcuts" "$HOME/.shortcuts/tasks" "$HOME/.termux"
  cat > "$HOME/.shortcuts/AvidKiya DevHub App" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
export AK_APP_DIR="$AK_APP_DIR"
"$AK_APP_DIR/bin/avid" app
EOF
  cat > "$HOME/.shortcuts/AvidKiya DevHub CLI" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
export AK_APP_DIR="$AK_APP_DIR"
"$AK_APP_DIR/bin/avid" code
EOF
  cat > "$HOME/.shortcuts/AvidKiya Web Panel" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
export AK_APP_DIR="$AK_APP_DIR"
"$AK_APP_DIR/bin/avid" web-start
EOF
  cat > "$HOME/.shortcuts/tasks/AvidKiya Health Check" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
export AK_APP_DIR="$AK_APP_DIR"
"$AK_APP_DIR/bin/avid" health-once
read -rp "Press Enter..." _
EOF
  chmod +x "$HOME/.shortcuts/AvidKiya DevHub App" "$HOME/.shortcuts/AvidKiya DevHub CLI" "$HOME/.shortcuts/AvidKiya Web Panel" "$HOME/.shortcuts/tasks/AvidKiya Health Check"
  if ! grep -q 'allow-external-apps' "$HOME/.termux/termux.properties" 2>/dev/null; then
    cat >> "$HOME/.termux/termux.properties" <<'EOF'

# AvidKiya DevHub integration
allow-external-apps = true
EOF
  fi
  echo "Shortcuts installed in ~/.shortcuts"
  echo "Install Termux:Widget from F-Droid, then add the AvidKiya widget/shortcut to Android home screen."
  echo "App shortcut: AvidKiya DevHub App"
}
app_menu(){
  while true; do
    ui_key_select "📱 AvidKiya App Mode - Android-like" \
      "Open DevHub as local mobile app" \
      "Install Android home-screen shortcuts - Termux:Widget" \
      "Start web app only" \
      "Stop web app" \
      "Web app status" \
      "Back"
    case $? in
      1) app_open; pause;;
      2) app_install_shortcuts; pause;;
      3) web_start_bg; pause;;
      4) web_stop; pause;;
      5) web_status; pause;;
      6|255) break;;
    esac
  done
}

# ---------- Ubuntu/base patch ----------
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

# ---------- AI CLI tools ----------
install_mimo(){ patch_ubuntu_full; ubuntu_run_logged 'export PATH="/root/.mimocode/bin:/usr/local/bin:/usr/bin:/bin:$PATH"; curl -fsSL https://mimo.xiaomi.com/install | bash || true; npm install -g @mimo-ai/cli || true; grep -q mimocode /root/.bashrc || echo "export PATH=\"/root/.mimocode/bin:\$PATH\"" >> /root/.bashrc; [ -x /root/.mimocode/bin/mimo ] && ln -sf /root/.mimocode/bin/mimo /usr/local/bin/mimo || true; source /root/.bashrc 2>/dev/null || true; command -v mimo || true'; }
install_claude(){ patch_ubuntu_full; ubuntu_run_logged 'npm install -g @anthropic-ai/claude-code || true; command -v claude || true'; }
install_gemini(){ patch_ubuntu_full; ubuntu_run_logged 'npm install -g @google/gemini-cli || true; command -v gemini || true'; }

# ---------- Local AI / llama.cpp ----------
local_ubuntu(){ ubuntu_ok || { echo "Ubuntu not ready. Install/Patch Ubuntu first."; return 1; }; }
local_install_llama(){ local_ubuntu || return 1; ubuntu_run_logged 'set -e; mkdir -p /root/.avid-devhub/src /root/.avid-devhub/models; apt update; apt install -y git build-essential cmake python3 curl wget ca-certificates; if [ ! -d /root/.avid-devhub/src/llama.cpp/.git ]; then git clone --depth 1 https://github.com/ggml-org/llama.cpp /root/.avid-devhub/src/llama.cpp; else cd /root/.avid-devhub/src/llama.cpp && git pull --ff-only || true; fi; cd /root/.avid-devhub/src/llama.cpp; if [ ! -x build/bin/llama-cli ] || [ ! -x build/bin/llama-server ]; then cmake -B build -DGGML_NATIVE=OFF -DGGML_OPENMP=OFF; cmake --build build --config Release -j$(nproc); else echo "llama.cpp already built. Skipping rebuild."; fi; ls -lh build/bin/llama-cli build/bin/llama-server 2>/dev/null || true'; }
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
local_download_custom(){ local_ubuntu || return 1; read -rp "GGUF URL: " url; read -rp "File name: " file; [ -z "$url" ] && return; [ -z "$file" ] && file="custom-model.gguf"; ubuntu_run_logged "mkdir -p /root/.avid-devhub/models; if [ -f /root/.avid-devhub/models/$file ]; then echo 'Model already exists. Skipping download.'; else wget -c -O /root/.avid-devhub/models/$file '$url'; fi; ls -lh /root/.avid-devhub/models/$file"; }
local_list_models(){ local_ubuntu || return 1; ubuntu_exec 'mkdir -p /root/.avid-devhub/models; ls -lh /root/.avid-devhub/models/*.gguf 2>/dev/null || echo "No GGUF models found."'; }
local_run_prompt(){ local_ubuntu || return 1; read -rp "Prompt: " prompt; ubuntu_exec "models=(/root/.avid-devhub/models/*.gguf); if [ ! -f \"\${models[0]}\" ]; then echo 'No GGUF model found.'; exit 1; fi; /root/.avid-devhub/src/llama.cpp/build/bin/llama-cli -m \"\${models[0]}\" -p \"$prompt\" -n 512"; }
local_start_server(){ local_ubuntu || return 1; ubuntu_run_logged "pkill -f llama-server || true; models=(/root/.avid-devhub/models/*.gguf); if [ ! -f \"\${models[0]}\" ]; then echo 'No GGUF model found.'; exit 1; fi; nohup /root/.avid-devhub/src/llama.cpp/build/bin/llama-server -m \"\${models[0]}\" --host 127.0.0.1 --port ${AK_LLAMA_PORT:-8080} > /root/.avid-devhub/llama-server.log 2>&1 & echo \$! > /root/.avid-devhub/llama-server.pid; echo 'Server: http://127.0.0.1:${AK_LLAMA_PORT:-8080}/v1/chat/completions'"; }
local_stop_server(){ local_ubuntu || return 1; ubuntu_exec 'pkill -f llama-server || true; rm -f /root/.avid-devhub/llama-server.pid; echo stopped'; }
local_agent_config(){ mkdir -p "$AK_AGENT_DIR"; python "$AK_AGENT_DIR/avid_agent.py" init >/dev/null 2>&1 || true; python - <<PY
import json, pathlib
p=pathlib.Path('$AK_AGENT_DIR/agent-config.json')
c=json.loads(p.read_text())
c['manager']='llama_local'; c['synthesizer']='llama_local'; c['workers']=['llama_local']
c.setdefault('providers',{})['llama_local']={'type':'openai_compatible','base_url':'http://127.0.0.1:${AK_LLAMA_PORT:-8080}/v1/chat/completions','model':'local-model','api_key_env':''}
p.write_text(json.dumps(c,indent=2,ensure_ascii=False))
print('Agent configured for llama_local. Start local server first.')
PY
}

# ---------- Cyber/dev installers ----------
cyber_essential(){ patch_ubuntu_full; ubuntu_apt_missing nmap netcat-openbsd whois dnsutils traceroute curl wget jq python3 git whatweb; }
cyber_recon(){ patch_ubuntu_full; ubuntu_apt_missing nmap netcat-openbsd whois dnsutils traceroute iproute2 net-tools whatweb wafw00f curl wget jq masscan; ubuntu_pipx_install rustscan 'pipx install rustscan || true'; }
cyber_web(){ patch_ubuntu_full; ubuntu_apt_missing nikto sqlmap whatweb wafw00f gobuster ffuf httpie python3-pip git; ubuntu_pipx_install dirsearch 'pipx install dirsearch || pip install -U dirsearch || true'; }
cyber_hash(){ patch_ubuntu_full; ubuntu_apt_missing john hashcat hashid wordlists crunch || ubuntu_apt_missing john hashid crunch; }
cyber_ctf(){ patch_ubuntu_full; ubuntu_apt_missing gdb gdbserver radare2 binutils strace ltrace file xxd python3-pip python3-venv; ubuntu_pipx_install pwn 'pipx install pwntools || pip install -U pwntools'; ubuntu_pipx_install checksec 'pipx install checksec || true'; }
cyber_forensics(){ patch_ubuntu_full; ubuntu_apt_missing binwalk exiftool file foremost steghide imagemagick xxd ruby; ubuntu_exec 'command -v zsteg >/dev/null 2>&1' && echo '✅ zsteg already installed.' || ubuntu_run_logged 'gem install zsteg || true'; }
cyber_reverse(){ patch_ubuntu_full; ubuntu_apt_missing gdb gdbserver radare2 binutils strace ltrace file xxd patchelf python3-pip; ubuntu_pipx_install checksec 'pipx install checksec || true'; }
cyber_osint(){ patch_ubuntu_full; ubuntu_apt_missing whois dnsutils traceroute theharvester spiderfoot || ubuntu_apt_missing whois dnsutils traceroute theharvester; ubuntu_pipx_install holehe 'pipx install holehe || pip install -U holehe || true'; }
cyber_api(){ patch_ubuntu_full; ubuntu_apt_missing curl wget jq httpie || true; ubuntu_pipx_install arjun 'pipx install arjun || pip install -U arjun || true'; }
cyber_mobile(){ patch_ubuntu_full; ubuntu_apt_missing apktool jadx android-tools-adb android-tools-fastboot || ubuntu_apt_missing apktool jadx; ubuntu_pipx_install objection 'pipx install objection || pip install -U objection || true'; }
cyber_wordlists(){ patch_ubuntu_full; ubuntu_apt_missing wordlists seclists crunch cewl || ubuntu_apt_missing wordlists crunch; ubuntu_exec 'mkdir -p /usr/share/wordlists; [ -f /usr/share/wordlists/rockyou.txt.gz ] && [ ! -f /usr/share/wordlists/rockyou.txt ] && gzip -dk /usr/share/wordlists/rockyou.txt.gz || true'; }
cyber_advanced(){ patch_ubuntu_full; echo "Advanced tools are optional and lab-only."; confirm_auth || return; ubuntu_run_logged 'apt install -y hydra metasploit-framework exploitdb searchsploit nuclei amass masscan responder enum4linux smbclient || apt install -y hydra exploitdb masscan enum4linux smbclient || true'; }
cyber_full(){ cyber_essential; cyber_recon; cyber_web; cyber_hash; cyber_ctf; cyber_forensics; cyber_reverse; cyber_osint; cyber_api; cyber_wordlists; }
cyber_health(){ ubuntu_ok || { echo Ubuntu not ready; return; }; ubuntu_exec 'for t in nmap masscan whatweb nikto sqlmap gobuster ffuf dirsearch nuclei amass hydra msfconsole searchsploit john hashcat hashid gdb radare2 binwalk exiftool steghide apktool jadx adb theHarvester arjun http; do if command -v $t >/dev/null 2>&1; then echo "[✓] $t: $(command -v $t)"; else echo "[ ] $t: missing"; fi; done'; }
safe_target(){ printf '%s' "$1" | grep -Eq '^[A-Za-z0-9._:/?=&%+#,@-]{1,220}$'; }
run_tool_prompt(){ local tool="$1" label="Target/URL/domain" target; read -rp "$label: " target; run_tool "$tool" "$target"; }
run_tool(){
  local tool="$1" target="$2"
  [ -n "$target" ] || { echo "Target required."; return 2; }
  safe_target "$target" || { echo "Invalid target characters."; return 2; }
  case "$tool" in
    nmap) confirm_auth || return 1; ubuntu_exec "nmap -sV --reason --top-ports 100 '$target'";;
    nmap-quick) confirm_auth || return 1; ubuntu_exec "nmap -T4 -F '$target'";;
    dig) ubuntu_exec "dig '$target' any +short";;
    headers) ubuntu_exec "curl -I -L --max-time 20 '$target'";;
    whatweb) confirm_auth || return 1; ubuntu_exec "whatweb '$target'";;
    wafw00f) confirm_auth || return 1; ubuntu_exec "wafw00f '$target'";;
    nikto) confirm_auth || return 1; ubuntu_exec "nikto -h '$target' -nointeractive";;
    whois) ubuntu_exec "whois '$target' | head -80";;
    *) echo "Unknown tool: $tool"; return 2;;
  esac
}
cyber_helpers(){ while true; do ui_key_select "Authorized Run Helpers" "Quick nmap scan" "Service nmap scan" "DNS lookup" "HTTP headers" "WhatWeb fingerprint" "WAFW00F check" "WHOIS lookup" "Nikto basic web check" "Back"; case $? in 1) read -rp "Target/IP/domain: " t; run_tool nmap-quick "$t"; pause;; 2) read -rp "Target/IP/domain: " t; run_tool nmap "$t"; pause;; 3) read -rp "Domain: " d; run_tool dig "$d"; pause;; 4) read -rp "URL: " u; run_tool headers "$u"; pause;; 5) read -rp "URL/domain: " u; run_tool whatweb "$u"; pause;; 6) read -rp "URL: " u; run_tool wafw00f "$u"; pause;; 7) read -rp "Domain/IP: " d; run_tool whois "$d"; pause;; 8) read -rp "URL/host: " u; run_tool nikto "$u"; pause;; 9|255) break;; esac; done; }
health_once(){ clear; banner; echo "🩺 Health Check"; echo; status_line; echo; echo "Termux tools:"; for t in fish curl git ruby lolcat proot-distro python; do has "$t" && echo "[✓] $t" || echo "[ ] $t"; done; echo; echo "Ubuntu tools:"; cyber_health; }
health_menu(){ health_once; pause; }
settings_menu(){ ${EDITOR:-nano} "$AK_CONFIG"; }
logs_menu(){ clear; ls -lh "$AK_LOG_DIR"; echo; read -rp "Open log file name or Enter back: " f; [ -n "$f" ] && ${PAGER:-less} "$AK_LOG_DIR/$f"; }

# ---------- Menus ----------
main_menu(){ ui_splash; while true; do ui_key_select "AvidKiya DevHub - Main" "🐧 Termux Environment" "☣️ Ubuntu Environment" "⚡ AvidKiya Agent" "🤖 AI CLI Tools" "🧠 Local AI Models" "🧰 Developer Tools" "🛡️ تست نفوذ / هک" "📱 App / 🌐 Web Panel" "🩺 Health Check / Repair" "⚙️ Settings" "📜 Logs" "🚪 Exit"; case $? in 1) termux_menu;; 2) ubuntu_menu;; 3) agent_menu;; 4) ai_menu;; 5) local_ai_menu;; 6) dev_menu;; 7) cyber_menu;; 8) app_menu;; 9) health_menu;; 10) settings_menu;; 11) logs_menu;; 12|255) break;; esac; done; }
termux_menu(){ while true; do ui_key_select "Termux Environment" "Update package lists only" "Upgrade Termux packages - ask first" "Install/Repair Fish + Oh My Fish + Batman" "Install missing essential Termux packages" "Setup Storage" "Back"; case $? in 1) pkg update -y; pause;; 2) read -rp "Run pkg upgrade? [y/N]: " a; [[ $a =~ ^[Yy] ]] && pkg upgrade -y; pause;; 3) run_termux_pkg fish curl; fish -lc 'type -q omf; or curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish'; fish -lc 'omf install batman; or true; omf theme batman; or omf batman; or true'; pause;; 4) run_termux_pkg termux-api python git ruby curl wget fish figlet screenfetch nano proot-distro nodejs openssh tmux jq ripgrep fd bat eza htop tree unzip zip; gem install lolcat --no-document || true; pause;; 5) termux-setup-storage || true; pause;; 6|255) break;; esac; done; }
ubuntu_menu(){ while true; do ui_key_select "Ubuntu Environment" "Run Ubuntu Shell" "Install Ubuntu container" "Patch/Repair Ubuntu Base + PATH + Fish/Batman" "Reinstall Ubuntu from zero - destructive" "Back"; case $? in 1) proot-distro login "${AK_UBUNTU_DISTRO}";; 2) has proot-distro || pkg install -y proot-distro; proot-distro install "${AK_UBUNTU_DISTRO}"; pause;; 3) patch_ubuntu_full; pause;; 4) read -rp "Type REINSTALL to delete Ubuntu: " x; [ "$x" = REINSTALL ] && { proot-distro remove "${AK_UBUNTU_DISTRO}"; proot-distro install "${AK_UBUNTU_DISTRO}"; patch_ubuntu_full; }; pause;; 5|255) break;; esac; done; }
agent_menu(){ while true; do ui_key_select "AvidKiya Agent" "Init agent config" "Show agent config" "Run agent prompt" "Add OpenAI-compatible provider" "Configure for local llama.cpp" "Back"; case $? in 1) python "$AK_AGENT_DIR/avid_agent.py" init; pause;; 2) python "$AK_AGENT_DIR/avid_agent.py" config; pause;; 3) read -rp "Prompt: " p; python "$AK_AGENT_DIR/avid_agent.py" run "$p"; pause;; 4) read -rp "Name: " n; read -rp "Base URL: " u; read -rp "Model: " m; read -rp "API key env var: " e; python "$AK_AGENT_DIR/avid_agent.py" add-provider "$n" "$u" "$m" "$e"; pause;; 5) local_agent_config; pause;; 6|255) break;; esac; done; }
ai_menu(){ while true; do ui_key_select "AI CLI Tools" "Install/Repair MiMo Code" "Run MiMo" "Install Claude Code" "Run Claude Code" "Install Gemini CLI" "Run Gemini CLI" "Install Aider" "Run Aider" "Install All Recommended AI Tools" "Back"; case $? in 1) install_mimo; pause;; 2) ubuntu_exec 'cd /root; source /root/.bashrc 2>/dev/null || true; command -v mimo >/dev/null 2>&1 && exec mimo || exec /root/.mimocode/bin/mimo';; 3) install_claude; pause;; 4) ubuntu_exec 'claude';; 5) install_gemini; pause;; 6) ubuntu_exec 'gemini';; 7) ubuntu_run_logged 'apt install -y pipx python3-venv; pipx ensurepath; pipx install aider-chat || pip install -U aider-chat'; pause;; 8) ubuntu_exec 'aider';; 9) install_mimo; install_claude; install_gemini; ubuntu_run_logged 'apt install -y pipx python3-venv; pipx ensurepath; pipx install aider-chat || pip install -U aider-chat'; pause;; 10|255) break;; esac; done; }
local_ai_menu(){ while true; do ui_key_select "Local AI Models - Offline / Private" "Install/Build llama.cpp inside Ubuntu" "Download recommended small model" "Download model from custom URL" "List local models" "Run local model prompt" "Start OpenAI-compatible local server" "Stop local server" "Configure Agent to use local model" "Back"; case $? in 1) local_install_llama; pause;; 2) local_download_recommended; pause;; 3) local_download_custom; pause;; 4) local_list_models; pause;; 5) local_run_prompt; pause;; 6) local_start_server; pause;; 7) local_stop_server; pause;; 8) local_agent_config; pause;; 9|255) break;; esac; done; }
dev_menu(){ while true; do ui_key_select "Developer Tools" "Install Node.js/npm tools" "Install Python/pipx tools" "Install Git/GitHub tools" "Install Terminal power tools" "Install All Dev Tools" "Back"; case $? in 1) ubuntu_run_logged 'apt install -y nodejs npm; npm install -g npm@latest pnpm yarn typescript ts-node nodemon'; pause;; 2) ubuntu_run_logged 'apt install -y python3 python3-pip python3-venv pipx; pipx ensurepath; pipx install poetry || true'; pause;; 3) ubuntu_run_logged 'apt install -y git gh || apt install -y git'; pause;; 4) ubuntu_run_logged 'apt install -y tmux htop tree jq ripgrep fd-find bat fzf screenfetch figlet ruby; gem install lolcat --no-document || true'; pause;; 5) ubuntu_run_logged 'apt install -y nodejs npm python3 python3-pip python3-venv pipx git tmux htop tree jq ripgrep fd-find bat fzf screenfetch figlet ruby build-essential'; pause;; 6|255) break;; esac; done; }
cyber_menu(){ while true; do ui_key_select "تست نفوذ / هک - Authorized Lab Only" "Install Essential Pack" "Install Recon & Network Mapping Pack" "Install Web Hacking Pack" "Install Password/Hash Auditing Pack" "Install CTF + Pwn Pack" "Install Forensics + Steganography Pack" "Install Reverse Engineering Pack" "Install OSINT Pack" "Install API Testing Pack" "Install Android/Mobile Hacking Lab Pack" "Install Wordlists Pack" "Install Advanced Optional Pack" "Install FULL Pentest/Hack Lab Pack" "Security Tools Health Check" "Authorized Run Helpers" "Back"; case $? in 1) cyber_essential; pause;; 2) cyber_recon; pause;; 3) cyber_web; pause;; 4) cyber_hash; pause;; 5) cyber_ctf; pause;; 6) cyber_forensics; pause;; 7) cyber_reverse; pause;; 8) cyber_osint; pause;; 9) cyber_api; pause;; 10) cyber_mobile; pause;; 11) cyber_wordlists; pause;; 12) cyber_advanced; pause;; 13) cyber_full; pause;; 14) cyber_health; pause;; 15) cyber_helpers;; 16|255) break;; esac; done; }
web_menu(){ while true; do ui_key_select "Local Web Control Panel / Mobile App" "Start mobile web app in background and open browser" "Start web app in foreground" "Stop background web app" "Web app status" "Back"; case $? in 1) web_start_bg; pause;; 2) web_install_flask; cd "$AK_WEB_DIR" && AK_APP_DIR="$AK_APP_DIR" AK_WEB_HOST="$AK_WEB_HOST" AK_WEB_PORT="$AK_WEB_PORT" python app.py; pause;; 3) web_stop; pause;; 4) web_status; pause;; 5|255) break;; esac; done; }

# ---------- Direct command router ----------
case "${1:-menu}" in
  menu) main_menu;;
  app) app_open;; app-menu) app_menu;; app-shortcuts) app_install_shortcuts;;
  tui|code) shift; python "$AK_APP_DIR/bin/avid-tui" "$@" 2>/dev/null || python "$AK_APP_DIR/scripts/avid_tui.py" "$@" 2>/dev/null || main_menu;;
  classic) AK_LAUNCHER_SHOWN="" AK_STARTUP_MODE="cli" . "$AK_APP_DIR/launcher.sh";;

  termux) termux_menu;;
  termux-update) pkg update -y;;
  termux-upgrade) read -rp "Run pkg upgrade? [y/N]: " a; [[ $a =~ ^[Yy] ]] && pkg upgrade -y || echo "Skipped.";;
  termux-fish) run_termux_pkg fish curl; fish -lc 'type -q omf; or curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish'; fish -lc 'omf install batman; or true; omf theme batman; or omf batman; or true';;
  termux-essential) run_termux_pkg termux-api python git ruby curl wget fish figlet screenfetch nano proot-distro nodejs openssh tmux jq ripgrep fd bat eza htop tree unzip zip; has lolcat || gem install lolcat --no-document || true;;
  termux-storage) [ -d "$HOME/storage" ] && echo "~/storage already exists." || termux-setup-storage || true;;

  ubuntu) ubuntu_menu;;
  ubuntu-shell) proot-distro login "${AK_UBUNTU_DISTRO}";;
  ubuntu-install) has proot-distro || pkg install -y proot-distro; if ubuntu_ok; then echo "Ubuntu already exists and works. Skipping install."; else proot-distro install "${AK_UBUNTU_DISTRO}"; fi;;
  ubuntu-patch) patch_ubuntu_full;;
  ubuntu-reinstall) read -rp "Type REINSTALL to delete Ubuntu: " x; [ "$x" = REINSTALL ] && { proot-distro remove "${AK_UBUNTU_DISTRO}"; proot-distro install "${AK_UBUNTU_DISTRO}"; patch_ubuntu_full; } || echo "Cancelled.";;

  agent) agent_menu;;
  agent-init) python "$AK_AGENT_DIR/avid_agent.py" init;;
  agent-config) python "$AK_AGENT_DIR/avid_agent.py" config;;
  agent-run) shift; python "$AK_AGENT_DIR/avid_agent.py" run "$@";;
  agent-run-interactive) read -rp "Prompt: " p; python "$AK_AGENT_DIR/avid_agent.py" run "$p";;
  local-agent) local_agent_config;;

  ai) ai_menu;;
  ai-mimo|install-mimo) install_mimo;;
  run-mimo) ubuntu_exec 'cd /root; source /root/.bashrc 2>/dev/null || true; command -v mimo >/dev/null 2>&1 && exec mimo || exec /root/.mimocode/bin/mimo';;
  ai-claude|install-claude) install_claude;;
  run-claude) ubuntu_exec 'claude';;
  ai-gemini|install-gemini) install_gemini;;
  run-gemini) ubuntu_exec 'gemini';;
  ai-aider|install-aider) ubuntu_run_logged 'apt install -y pipx python3-venv; pipx ensurepath; pipx install aider-chat || pip install -U aider-chat';;
  run-aider) ubuntu_exec 'aider';;
  ai-all) install_mimo; install_claude; install_gemini; ubuntu_run_logged 'apt install -y pipx python3-venv; pipx ensurepath; pipx install aider-chat || pip install -U aider-chat';;

  local-ai) local_ai_menu;;
  local-ai-install|local-install) local_install_llama;;
  local-download) local_download_recommended;;
  local-download-custom) local_download_custom;;
  local-list) local_list_models;;
  local-run) local_run_prompt;;
  local-ai-server|local-server-start) local_start_server;;
  local-server-stop) local_stop_server;;

  dev-node) ubuntu_run_logged 'apt install -y nodejs npm; npm install -g npm@latest pnpm yarn typescript ts-node nodemon';;
  dev-python) ubuntu_run_logged 'apt install -y python3 python3-pip python3-venv pipx; pipx ensurepath; pipx install poetry || true';;
  dev-git) ubuntu_run_logged 'apt install -y git gh || apt install -y git';;
  dev-terminal) ubuntu_run_logged 'apt install -y tmux htop tree jq ripgrep fd-find bat fzf screenfetch figlet ruby; gem install lolcat --no-document || true';;
  dev-all) ubuntu_run_logged 'apt install -y nodejs npm python3 python3-pip python3-venv pipx git tmux htop tree jq ripgrep fd-find bat fzf screenfetch figlet ruby build-essential; npm install -g npm@latest pnpm yarn typescript ts-node nodemon || true';;

  security|cyber) cyber_menu;;
  run-tool) shift; run_tool "$@";;
  run-tool-prompt) shift; run_tool_prompt "$@";;
  cyber-essential) cyber_essential;; cyber-recon) cyber_recon;; cyber-web) cyber_web;; cyber-hash) cyber_hash;; cyber-ctf) cyber_ctf;; cyber-forensics) cyber_forensics;; cyber-reverse) cyber_reverse;; cyber-osint) cyber_osint;; cyber-api) cyber_api;; cyber-mobile) cyber_mobile;; cyber-wordlists) cyber_wordlists;; cyber-advanced) cyber_advanced;; cyber-full) cyber_full;; cyber-health) cyber_health;; cyber-helpers) cyber_helpers;;

  web) web_menu;; web-start) web_start_bg;; web-stop) web_stop;; web-status) web_status;;
  web-foreground) web_install_flask; cd "$AK_WEB_DIR" && AK_APP_DIR="$AK_APP_DIR" AK_WEB_HOST="$AK_WEB_HOST" AK_WEB_PORT="$AK_WEB_PORT" python app.py;;
  health) health_menu;; health-once) health_once;; settings) settings_menu;; logs) logs_menu;;
  *) main_menu;;
esac
