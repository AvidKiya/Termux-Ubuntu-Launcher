# Avid Kiya Termux Ubuntu Launcher

**فارسی:** لانچر منویی زیبا برای Termux که موقع باز شدن هر سشن، بین Termux، Ubuntu و نصب Ubuntu انتخاب می‌دهد.  
**English:** An upgraded version of the classic Avid Kiya fish theme, plus a beautiful startup menu for Termux that lets you choose Termux, Ubuntu, install Ubuntu, or open a normal Termux session.

---

## نصب سریع / Quick Install

```bash
pkg update -y
pkg install -y git

git clone https://github.com/AvidKiya/Termux-Ubuntu-Launcher.git
cd avid-termux-ubuntu-launcher
bash install.sh
```

بعد Termux را ببندید و دوباره باز کنید، یا اجرا کنید:

```bash
source ~/.bashrc
```

If you are inside fish, do not run `source ~/.bashrc`. Use this instead:

```bash
exec bash -i
```

Then use:

```text
1. 🐧 Run Termux
2. ☣️ Run Ubuntu
3. ⚙️ Ubuntu installer
4. 🚪 Exit - Opening Termux normally
```

> First choose option `3` once to install Ubuntu. After that, option `2` opens a real Ubuntu proot shell.

---

## Documentation

- [راهنمای فارسی](docs/README.fa.md)
- [English Guide](docs/README.en.md)

---

## Classic base

This project extends the old setup:

```bash
pkg update
pkg upgrade
pkg install termux-api python git ruby curl fish figlet screenfetch nano
curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish
omf install batman
gem install lolcat
```

Option 1 keeps the classic flow:

```bash
clear
screenfetch | lolcat
figlet + Avid Kiya + | lolcat
curl -s wttr.in/36.46,52.86 | head -7
date | lolcat
fish
```

## Features

- Auto-start menu from `~/.bashrc`
- Installs fish, Oh My Fish, and batman theme
- Termux banner with Android/system info
- Ubuntu banner after entering Ubuntu
- Real Ubuntu installation using `proot-distro`
- Weather from `wttr.in/36.46,52.86`
- Optional `lolcat` colors
- Safe uninstall script
- Config file at `~/.termux-avid-kiya/config`
- Rewrites `~/.bashrc` from zero after backing it up
- Ubuntu PATH/development patch for tools that need `patch`, `gcc`, `make`, etc.



## Android-like App Mode / حالت شبیه APK

App Mode starts the local web panel and opens it on Android like a mobile app:

```bash
avid app
```

Install Android home-screen shortcuts:

```bash
avid app-shortcuts
```

Then install **Termux:Widget** from F-Droid and add `AvidKiya DevHub App` to your Android home screen. This gives an APK-like launcher experience while keeping everything local in Termux.

Modes:

```text
App  = start localhost web app + open browser/custom tab
Web  = start localhost web panel only
CLI  = AvidKiya terminal menu / avid code
```

## تست نفوذ / هک

The security section is now named **تست نفوذ / هک** and includes real lab profiles: Essential, Recon, Web Hacking, Hash Audit, CTF/Pwn, Forensics, Reverse Engineering, OSINT, API Testing, Android/Mobile Hacking Lab, Wordlists, Advanced Optional and FULL Pack.

Use only for your own systems, CTF, university labs, and authorized testing.

## v3.9 AvidKiya DevHub CODE TUI

The project now includes a dedicated MiMo-inspired terminal UI for AvidKiya DevHub:

```bash
avid code
# or
avid tui
```

It keeps the original classic launcher intact, but adds a richer full-screen terminal experience:

- black starfield background
- centered `AvidKiya / AVID DEVHUB CODE` logo
- arrow-key menu selection and Enter confirm
- command/input box like modern AI CLIs
- slash command palette: `/web`, `/ai`, `/agent`, `/local`, `/ubuntu`, `/termux`, `/cyber`, `/dev`, `/ask PROMPT`
- MiMo-style hint line: `tab switch mode   ctrl+p settings   @ attach file   $ subagent   / commands`

Startup uses this TUI automatically when:

```bash
AK_STARTUP_MODE="ask"
AK_CLI_THEME="mimo"
```

To force the old classic launcher:

```bash
nano ~/.termux-avid-kiya/config
AK_CLI_THEME="classic"
AK_STARTUP_MODE="cli"
```


---

## Uninstall

```bash
cd avid-termux-ubuntu-launcher
bash uninstall.sh
```

To remove Ubuntu too:

```bash
proot-distro remove ubuntu
```

---

## License

MIT


## MiMo Code support

Menu option 3 patches Ubuntu and tries to install MiMo Code automatically. It installs Node.js/npm and then runs:

```bash
npm install -g @mimo-ai/cli
```

If that fails, it also tries the official installer:

```bash
curl -fsSL https://mimo.xiaomi.com/install | bash
```

After patching, option 2 should show the MiMo path if `mimo` is available.


## Final MiMo command-not-found fix

MiMo is often installed at:

```bash
/root/.mimocode/bin/mimo
```

Menu option 3 now automatically adds this path to PATH, writes it to `/root/.bashrc`, sources `/root/.bashrc`, and creates this symlink when possible:

```bash
ln -sf /root/.mimocode/bin/mimo /usr/local/bin/mimo
```

After running option 3, this should work inside Ubuntu:

```bash
mimo
```


## Oh My Fish and batman inside Ubuntu

Menu option 3 also installs and enables fish + Oh My Fish + batman inside Ubuntu:

```bash
apt install -y fish
curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish
omf install batman
omf theme batman
```

Option 2 shows the Ubuntu banner first, then opens fish/batman by default. To disable it:

```bash
nano ~/.termux-avid-kiya/config
AK_AUTO_FISH_AFTER_UBUNTU="0"
```


## v3.1 Web Panel

The local web panel is now multi-page and bilingual-style. Run:

```bash
avid web
```

Open:

```text
http://127.0.0.1:8765
```

Pages:

- Dashboard
- AI Tools
- Cybersecurity Lab
- Developer Tools
- Ubuntu
- Settings
- Logs

The web panel can start non-interactive install/repair tasks in the background and saves output to:

```bash
~/.termux-avid-kiya/logs/
```

Interactive tools such as MiMo, Claude Code, Gemini CLI, and shells should still be run from the terminal menu:

```bash
avid
```


## Startup behavior

After running `bash install.sh`, every new Termux session opens the full Avid Kiya DevHub menu automatically. If you still see the old 4-option menu, reinstall once:

```bash
cd termux-ubuntu-launcher
git pull
bash install.sh
exec bash -i
```

You can always open the hub manually with:

```bash
avid
```


## v3.4 Mobile Web Panel

The web panel was rebuilt for phones:

- mobile-first bottom navigation
- faster cached status checks
- background tasks
- Tasks page
- better Logs page
- Persian/English layout
- safer localhost-only default

Run:

```bash
avid web
```

Open:

```text
http://127.0.0.1:8765
```


## AvidKiya Final Vision

Repository: https://github.com/AvidKiya/Termux-Ubuntu-Launcher

Author / handle: @AvidKiya

Startup can ask which experience you want:

1. App Mode - opens the mobile local web app
2. CLI Mode - classic Termux/Ubuntu launcher
3. Web Panel
4. Full DevHub terminal menu
5. Normal shell

Set it in `~/.termux-avid-kiya/config`:

```bash
AK_STARTUP_MODE="ask"   # ask, app, cli, web, shell
```

### AI Agent Policy

AvidKiya DevHub supports AI tools through safe and legitimate methods: official APIs, official CLIs, OAuth/device login when provided by vendors, local models, and user-provided configuration. It does not scrape browser tokens, steal sessions, bypass paid APIs, or automate logins in a way that violates service terms. This keeps the project safe for GitHub, university review, and public use.

Planned safe agent features: multi-provider routing, MiMo/Claude/Gemini CLI adapters, local model adapters, project memory, task planning, tool calling with user approval, and parallel model comparison using authorized providers.


## Local AI Models / Offline Agent

AvidKiya DevHub can run offline/private GGUF models through llama.cpp inside Ubuntu.

Open:

```bash
avid local-ai
```

Features:

- install/build llama.cpp
- download recommended small GGUF models
- download custom GGUF URL
- run prompt locally
- start OpenAI-compatible local server
- configure AvidKiya Agent to use `llama_local`

Recommended phone-friendly models:

- TinyLlama 1.1B Chat Q4_K_M
- Qwen2.5 0.5B Instruct Q4_K_M
- Qwen2.5 1.5B Instruct Q4_K_M
- Phi-3 Mini 4K Instruct Q4, heavier

This requires no API key and works offline after the model is downloaded.
