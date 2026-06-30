#!/usr/bin/env python3
"""AvidKiya DevHub PC launcher for Windows/macOS/Linux/VS Code terminals.
This is a cross-platform companion: it runs the web panel, opens the app UI,
provides local helpers and forwards Termux/Ubuntu-only operations when available.
"""
from __future__ import annotations
import argparse, http.server, json, os, platform, shutil, socketserver, subprocess, sys, threading, time, webbrowser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "web"
PORT = int(os.environ.get("AK_WEB_PORT", "8765"))
HOST = os.environ.get("AK_WEB_HOST", "127.0.0.1")

def run(cmd: list[str] | str, shell=False):
    print("$", cmd if isinstance(cmd,str) else " ".join(cmd))
    return subprocess.call(cmd, shell=shell)

def have(cmd: str) -> bool: return shutil.which(cmd) is not None

def serve_static():
    os.chdir(WEB)
    Handler = http.server.SimpleHTTPRequestHandler
    with socketserver.TCPServer((HOST, PORT), Handler) as httpd:
        print(f"AvidKiya static web panel: http://{HOST}:{PORT}")
        httpd.serve_forever()

def web_panel(open_browser=True):
    env=os.environ.copy(); env.setdefault("AK_APP_DIR", str(ROOT))
    if (WEB/"app.py").exists() and have("python") or have("python3"):
        py = shutil.which("python") or shutil.which("python3")
        try:
            import flask  # type: ignore
            if open_browser:
                threading.Timer(1.2, lambda: webbrowser.open(f"http://{HOST}:{PORT}/?mode=pc")).start()
            return subprocess.call([py, str(WEB/"app.py")], env=env)
        except Exception:
            print("Flask not installed. Static fallback will run. Install Flask with: pip install flask")
    if open_browser: threading.Timer(.8, lambda: webbrowser.open(f"http://{HOST}:{PORT}/templates/index.html")).start()
    serve_static()

def status():
    tools=["python","git","node","npm","nmap","curl","code","powershell","pwsh","bash"]
    print("AvidKiya PC Status")
    print("OS:", platform.platform())
    print("Project:", ROOT)
    for t in tools: print(("✅" if have(t) else "❌"), t, shutil.which(t) or "missing")

def cli():
    tui=ROOT/"scripts"/"avid_tui.py"
    if tui.exists(): return subprocess.call([sys.executable, str(tui)])
    print("TUI not found")
    return 1

def main():
    ap=argparse.ArgumentParser(prog="avid-pc", description="AvidKiya DevHub PC/VS Code launcher")
    sub=ap.add_subparsers(dest="cmd")
    sub.add_parser("web"); sub.add_parser("app"); sub.add_parser("cli"); sub.add_parser("status")
    p_run=sub.add_parser("run"); p_run.add_argument("tool"); p_run.add_argument("target", nargs="?")
    ns=ap.parse_args()
    if ns.cmd in (None,"app","web"): return web_panel(open_browser=True)
    if ns.cmd=="cli": return cli()
    if ns.cmd=="status": return status()
    if ns.cmd=="run":
        if ns.tool=="nmap" and ns.target and have("nmap"): return run(["nmap","-sV",ns.target])
        print("Tool missing or unsupported on this PC. Install it normally, or use Termux/Ubuntu backend.")
        return 2
if __name__=="__main__": raise SystemExit(main() or 0)
