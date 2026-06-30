#!/usr/bin/env python3
# AvidKiya DevHub CODE TUI
# MiMo-inspired private TUI for AvidKiya DevHub. No MiMo code is copied.
from __future__ import annotations
import curses, os, random, shutil, subprocess, sys, textwrap, time
from dataclasses import dataclass
from typing import Callable, Optional

APP_DIR = os.environ.get("AK_APP_DIR", os.path.expanduser("~/.termux-avid-kiya"))
BACKEND = os.path.join(APP_DIR, "bin", "avid")
if not os.path.exists(BACKEND):
    here = os.path.abspath(os.path.dirname(__file__))
    cand = os.path.join(here, "avid.sh")
    if os.path.exists(cand):
        BACKEND = cand
    else:
        cand = os.path.join(os.path.abspath(os.path.join(here, "..")), "scripts", "avid.sh")
        if os.path.exists(cand): BACKEND = cand
HANDLE = os.environ.get("AK_HANDLE", "@AvidKiya")

@dataclass
class Action:
    title: str
    hint: str
    cmd: Optional[list[str]] = None
    submenu: Optional[str] = None
    shell: bool = False

MENUS: dict[str, tuple[str, list[Action]]] = {
    "main": ("AvidKiya DevHub - Main", [
        Action("🐧 Termux Environment", "classic Termux tools, fish, packages", submenu="termux"),
        Action("☣️ Ubuntu Environment", "run/install/patch Ubuntu proot", submenu="ubuntu"),
        Action("⚡ AvidKiya Agent", "official APIs, CLIs, local models", submenu="agent"),
        Action("🤖 AI CLI Tools", "MiMo, Claude Code, Gemini, Aider", submenu="ai"),
        Action("🧠 Local AI Models", "llama.cpp + GGUF offline models", submenu="local"),
        Action("🧰 Developer Tools", "node, python, git, terminal power tools", submenu="dev"),
        Action("🛡️ تست نفوذ / هک", "authorized lab / CTF only", submenu="cyber"),
        Action("📱 App / 🌐 Web Panel", "Android-like app mode + localhost site", submenu="web"),
        Action("🩺 Health Check / Repair", "diagnose launcher, tools, Ubuntu", cmd=[BACKEND, "health"]),
        Action("⚙️ Settings", "edit ~/.termux-avid-kiya/config", cmd=[BACKEND, "settings"]),
        Action("📜 Logs", "open logs directory", cmd=[BACKEND, "logs"]),
        Action("🚪 Exit", "return to shell", shell=True),
    ]),
    "startup": ("Choose startup experience", [
        Action("📱 App Mode - Android-like launcher", "start localhost web app + open as mobile app", cmd=[BACKEND, "app"]),
        Action("💻 CLI Mode - classic Termux/Ubuntu launcher", "restore original 5-option launcher", cmd=[BACKEND, "classic"]),
        Action("🌐 Web Panel - start local web app", "http://127.0.0.1:8765", cmd=[BACKEND, "web-start"]),
        Action("🚀 Full DevHub terminal menu", "this MiMo-inspired terminal UI", submenu="main"),
        Action("🐚 Normal Shell", "do nothing", shell=True),
    ]),
    "termux": ("Termux Environment", [
        Action("Update package lists only", "asks internet only for repository metadata", cmd=[BACKEND, "termux-update"]),
        Action("Upgrade Termux packages - ask first", "never automatic", cmd=[BACKEND, "termux-upgrade"]),
        Action("Install/Repair Fish + Oh My Fish + Batman", "skip installed parts", cmd=[BACKEND, "termux-fish"]),
        Action("Install missing essential Termux packages", "dpkg-aware install", cmd=[BACKEND, "termux-essential"]),
        Action("Setup Storage", "skip if ~/storage exists", cmd=[BACKEND, "termux-storage"]),
        Action("← Back", "main menu", submenu="back"),
    ]),
    "ubuntu": ("Ubuntu Environment", [
        Action("Run Ubuntu Shell", "proot-distro login ubuntu", cmd=[BACKEND, "ubuntu-shell"]),
        Action("Install Ubuntu container", "only if missing", cmd=[BACKEND, "ubuntu-install"]),
        Action("Patch/Repair Ubuntu + PATH + MiMo fixer", "non-destructive repair", cmd=[BACKEND, "ubuntu-patch"]),
        Action("Reinstall Ubuntu from zero - destructive", "requires confirmation", cmd=[BACKEND, "ubuntu-reinstall"]),
        Action("← Back", "main menu", submenu="back"),
    ]),
    "agent": ("AvidKiya Agent", [
        Action("Init agent config", "create safe official/local config", cmd=[BACKEND, "agent-init"]),
        Action("Show agent config", "providers and roles", cmd=[BACKEND, "agent-config"]),
        Action("Run agent prompt", "manager/worker/synthesizer flow", cmd=[BACKEND, "agent-run-interactive"]),
        Action("Configure for local llama.cpp", "offline provider llama_local", cmd=[BACKEND, "local-agent"]),
        Action("← Back", "main menu", submenu="back"),
    ]),
    "ai": ("AI CLI Tools", [
        Action("Install/Repair MiMo Code", "official installer/npm only", cmd=[BACKEND, "install-mimo"]),
        Action("Run MiMo", "inside Ubuntu", cmd=[BACKEND, "run-mimo"]),
        Action("Install Claude Code", "official CLI", cmd=[BACKEND, "install-claude"]),
        Action("Run Claude Code", "inside Ubuntu", cmd=[BACKEND, "run-claude"]),
        Action("Install Gemini CLI", "official CLI", cmd=[BACKEND, "install-gemini"]),
        Action("Run Gemini CLI", "inside Ubuntu", cmd=[BACKEND, "run-gemini"]),
        Action("Install Aider", "pipx/pip", cmd=[BACKEND, "install-aider"]),
        Action("Run Aider", "inside Ubuntu", cmd=[BACKEND, "run-aider"]),
        Action("← Back", "main menu", submenu="back"),
    ]),
    "local": ("Local AI Models - Offline / Private", [
        Action("Install/Build llama.cpp inside Ubuntu", "build llama-cli and llama-server", cmd=[BACKEND, "local-install"]),
        Action("Download recommended small model", "TinyLlama/Qwen/Phi list", cmd=[BACKEND, "local-download"]),
        Action("Download model from custom URL", "GGUF URL", cmd=[BACKEND, "local-download-custom"]),
        Action("List local models", "~/.avid-devhub/models", cmd=[BACKEND, "local-list"]),
        Action("Run local model prompt", "offline llama-cli", cmd=[BACKEND, "local-run"]),
        Action("Start OpenAI-compatible local server", "localhost:8080/v1", cmd=[BACKEND, "local-server-start"]),
        Action("Stop local server", "pkill llama-server", cmd=[BACKEND, "local-server-stop"]),
        Action("Configure Agent to use local model", "llama_local", cmd=[BACKEND, "local-agent"]),
        Action("← Back", "main menu", submenu="back"),
    ]),
    "dev": ("Developer Tools", [
        Action("Install Node.js/npm tools", "typescript, pnpm, yarn", cmd=[BACKEND, "dev-node"]),
        Action("Install Python/pipx tools", "pipx, poetry", cmd=[BACKEND, "dev-python"]),
        Action("Install Git/GitHub tools", "git, gh", cmd=[BACKEND, "dev-git"]),
        Action("Install Terminal power tools", "tmux, fzf, ripgrep, bat", cmd=[BACKEND, "dev-terminal"]),
        Action("Install All Dev Tools", "complete developer profile", cmd=[BACKEND, "dev-all"]),
        Action("← Back", "main menu", submenu="back"),
    ]),
    "cyber": ("تست نفوذ / هک - Authorized Lab Only", [
        Action("Install Essential Security Pack", "nmap, whois, dnsutils, whatweb", cmd=[BACKEND, "cyber-essential"]),
        Action("Install Recon & Network Mapping Pack", "authorized recon", cmd=[BACKEND, "cyber-recon"]),
        Action("Install Web Security Testing Pack", "lab/CTF only", cmd=[BACKEND, "cyber-web"]),
        Action("Install Password/Hash Auditing Pack", "legal hash auditing", cmd=[BACKEND, "cyber-hash"]),
        Action("Install CTF + Pwn Pack", "gdb, pwntools, checksec", cmd=[BACKEND, "cyber-ctf"]),
        Action("Install Forensics + Steganography Pack", "binwalk, exiftool, steghide", cmd=[BACKEND, "cyber-forensics"]),
        Action("Install Reverse Engineering Pack", "radare2, strace, ltrace", cmd=[BACKEND, "cyber-reverse"]),
        Action("Install OSINT Pack", "theHarvester, SpiderFoot, holehe", cmd=[BACKEND, "cyber-osint"]),
        Action("Install API Testing Pack", "httpie, arjun, jq", cmd=[BACKEND, "cyber-api"]),
        Action("Install Android/Mobile Hacking Lab Pack", "apktool, jadx, adb, objection", cmd=[BACKEND, "cyber-mobile"]),
        Action("Install Wordlists Pack", "seclists, rockyou, crunch", cmd=[BACKEND, "cyber-wordlists"]),
        Action("Install Advanced Optional Pack", "hydra, metasploit, nuclei, amass", cmd=[BACKEND, "cyber-advanced"]),
        Action("Run Quick nmap scan", "authorized target prompt", cmd=[BACKEND, "run-tool-prompt", "nmap-quick"]),
        Action("Run HTTP headers", "URL prompt", cmd=[BACKEND, "run-tool-prompt", "headers"]),
        Action("Run WhatWeb fingerprint", "authorized URL prompt", cmd=[BACKEND, "run-tool-prompt", "whatweb"]),
        Action("Security Tools Health Check", "show installed/missing", cmd=[BACKEND, "cyber-health"]),
        Action("Authorized Run Helpers", "requires AUTHORIZED", cmd=[BACKEND, "cyber-helpers"]),
        Action("← Back", "main menu", submenu="back"),
    ]),
    "web": ("Local Web Control Panel / Mobile App", [
        Action("Open App Mode", "local web app + Android browser/custom tab", cmd=[BACKEND, "app"]),
        Action("Install Android home-screen shortcuts", "Termux:Widget shortcuts", cmd=[BACKEND, "app-shortcuts"]),
        Action("Start mobile web app in background", "fast Flask panel", cmd=[BACKEND, "web-start"]),
        Action("Start web app in foreground", "debug/visible server", cmd=[BACKEND, "web-foreground"]),
        Action("Stop background web app", "kill stored PID", cmd=[BACKEND, "web-stop"]),
        Action("Web app status", "PID and URL", cmd=[BACKEND, "web-status"]),
        Action("← Back", "main menu", submenu="back"),
    ]),
}

class TUI:
    def __init__(self, stdscr, start="main"):
        self.s = stdscr
        self.menu = start
        self.stack: list[str] = []
        self.idx = 0
        self.message = "Build · AvidKiya Auto (official APIs + local GGUF)"
        self.command = ""
        self.stars: list[tuple[int,int,str,int]] = []
        self.last_star = 0.0
        curses.curs_set(0)
        self.s.nodelay(False)
        self.s.keypad(True)
        curses.start_color(); curses.use_default_colors()
        pairs = [(1, 208), (2, 245), (3, 51), (4, 141), (5, 82), (6, 203), (7, 220)]
        for n, fg in pairs:
            try: curses.init_pair(n, fg, -1)
            except Exception: pass

    def color(self, n, bold=False):
        attr = curses.color_pair(n)
        return attr | (curses.A_BOLD if bold else 0)

    def add(self, y, x, txt, attr=0):
        h,w = self.s.getmaxyx()
        if 0 <= y < h and x < w:
            try: self.s.addnstr(y, max(0,x), txt[max(0,-x):], max(0, w-max(0,x)-1), attr)
            except Exception: pass

    def center(self, y, txt, attr=0):
        _,w = self.s.getmaxyx(); self.add(y, (w-len(txt))//2, txt, attr)

    def seed_stars(self):
        h,w = self.s.getmaxyx()
        density = max(16, (h*w)//190)
        chars = ["✦","✧","·"," "]
        self.stars = [(random.randrange(max(1,h)), random.randrange(max(1,w)), random.choice(chars[:3]), random.choice([2,2,7])) for _ in range(density)]

    def draw_stars(self):
        h,w = self.s.getmaxyx()
        if not self.stars or time.time()-self.last_star > 0.8:
            self.seed_stars(); self.last_star = time.time()
        for y,x,ch,c in self.stars:
            if y < h and x < w: self.add(y,x,ch,self.color(c))

    def draw_box(self, y, x, h, w, title=""):
        if w < 8 or h < 3: return
        top = "╭" + "─"*(w-2) + "╮"; mid = "│" + " "*(w-2) + "│"; bot = "╰" + "─"*(w-2) + "╯"
        self.add(y,x,top,self.color(2));
        for i in range(1,h-1): self.add(y+i,x,mid,self.color(2))
        self.add(y+h-1,x,bot,self.color(2))
        if title: self.add(y,x+2," " + title + " ", self.color(1, True))

    def draw(self):
        self.s.erase(); h,w = self.s.getmaxyx(); self.draw_stars()
        compact = h < 25 or w < 70
        top = 1 if compact else 2
        self.center(top, "AvidKiya", self.color(2))
        self.center(top+1, "AVID DEVHUB CODE", self.color(1, True))
        self.center(top+2, "Type / for commands   ·   Arrow keys select   ·   Enter confirm", self.color(2))
        title, actions = MENUS[self.menu]
        box_w = min(w-4, 72); box_h = min(len(actions)+6, h-8)
        y = max(top+4, (h-box_h)//2); x = (w-box_w)//2
        self.draw_box(y,x,box_h,box_w,title)
        visible = actions[:max(1, box_h-5)]
        if self.idx >= len(actions): self.idx = len(actions)-1
        for i,a in enumerate(visible):
            yy = y+2+i
            selected = i == self.idx
            marker = "➜" if selected else " "
            attr = self.color(1, True) if selected else self.color(0) if False else curses.A_NORMAL
            self.add(yy,x+3, f"{marker} {a.title}", attr)
            if selected and box_w > 54: self.add(yy, x+box_w-24, a.hint[:21], self.color(2))
        input_y = y+box_h-3
        prompt = self.command if self.command else "Type your message... (type / for commands)"
        self.add(input_y, x+3, "╭" + "─"*(box_w-8) + "╮", self.color(2))
        self.add(input_y+1, x+3, "│ " + prompt[:box_w-12].ljust(box_w-10) + "│", self.color(2 if not self.command else 3))
        if y+box_h < h-1:
            self.center(h-2, "tab switch mode   ctrl+p settings   @ attach file   $ subagent   / commands", self.color(2))
        self.center(h-1, f"{self.message[:w-2]}   {HANDLE}", self.color(7))
        self.s.refresh()

    def run_action(self, a: Action):
        if a.shell: return "exit"
        if a.submenu:
            if a.submenu == "back":
                self.menu = self.stack.pop() if self.stack else "main"
            else:
                self.stack.append(self.menu); self.menu = a.submenu
            self.idx = 0; return None
        if a.cmd:
            curses.endwin()
            print("\n╭" + "─"*58 + "╮")
            print("│ ◆ " + a.title[:52].ljust(54) + "│")
            print("╰" + "─"*58 + "╯")
            try:
                env=os.environ.copy(); env["AK_NO_MOTD"]="1"
                code=subprocess.call(a.cmd, env=env)
                print("\n" + ("✅ Done" if code==0 else f"⚠️ Finished with code {code}"))
            except FileNotFoundError:
                print("Backend not found:", " ".join(a.cmd))
            input("\nPress Enter to return to AvidKiya DevHub CODE...")
            self.s.clear(); curses.doupdate()
            return None

    def command_palette(self):
        self.command = "/"
        curses.curs_set(1); self.s.nodelay(False)
        while True:
            self.draw(); ch = self.s.getch()
            if ch in (27,): self.command=""; break
            if ch in (10,13):
                cmd = self.command.strip().lower(); self.command=""
                if cmd in ("/q","/quit","/exit"): curses.curs_set(0); return "exit"
                routes = {"/web":"web", "/ai":"ai", "/agent":"agent", "/local":"local", "/ubuntu":"ubuntu", "/termux":"termux", "/cyber":"cyber", "/dev":"dev", "/main":"main"}
                if cmd in routes: self.stack.append(self.menu); self.menu=routes[cmd]; self.idx=0
                elif cmd.startswith("/ask "):
                    curses.endwin(); subprocess.call([BACKEND,"agent-run",cmd[5:]]); input("\nEnter...")
                else: self.message="Commands: /web /ai /agent /local /ubuntu /termux /cyber /dev /ask PROMPT /quit"
                break
            if ch in (curses.KEY_BACKSPACE, 127, 8): self.command = self.command[:-1]
            elif 32 <= ch <= 126 and len(self.command)<80: self.command += chr(ch)
        curses.curs_set(0)

    def loop(self):
        while True:
            self.draw(); ch = self.s.getch(); title, actions = MENUS[self.menu]
            if ch in (ord('q'), ord('Q')):
                if self.stack: self.menu=self.stack.pop(); self.idx=0
                else: break
            elif ch == curses.KEY_UP: self.idx = (self.idx-1) % len(actions)
            elif ch == curses.KEY_DOWN: self.idx = (self.idx+1) % len(actions)
            elif ch in (9,): self.menu = "main" if self.menu != "main" else "web"; self.idx=0
            elif ch == 16: subprocess.call([BACKEND,"settings"])
            elif ch == ord('/'):
                if self.command_palette() == "exit": break
            elif ch in (10,13):
                if self.run_action(actions[self.idx]) == "exit": break
            elif ord('1') <= ch <= ord('9'):
                n=ch-ord('1')
                if n < len(actions):
                    self.idx=n
                    if self.run_action(actions[self.idx]) == "exit": break

def fallback(start="main"):
    print("AvidKiya / AVID DEVHUB CODE")
    title, actions = MENUS.get(start, MENUS["main"])
    while True:
        print("\n"+title)
        for i,a in enumerate(actions,1): print(f"{i}. {a.title} - {a.hint}")
        c=input("Choose: ").strip()
        if not c or c.lower()=="q": return
        if c.isdigit() and 1 <= int(c) <= len(actions):
            a=actions[int(c)-1]
            if a.submenu and a.submenu != "back": start=a.submenu; title,actions=MENUS[start]; continue
            if a.cmd: subprocess.call(a.cmd)
            if a.shell or a.submenu=="back": return

def main():
    start = "startup" if "--startup" in sys.argv else "main"
    if not sys.stdin.isatty() or not sys.stdout.isatty(): return fallback(start)
    try: curses.wrapper(lambda s: TUI(s,start).loop())
    except Exception as e:
        print("TUI fallback:", e); fallback(start)

if __name__ == "__main__": main()
