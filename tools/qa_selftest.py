#!/usr/bin/env python3
"""AvidKiya DevHub self-test / doctor.
Runs offline checks for project integrity, syntax, route availability and web pages.
"""
from __future__ import annotations
import json, os, pathlib, py_compile, re, shutil, subprocess, sys
ROOT = pathlib.Path(__file__).resolve().parents[1]
if not (ROOT/'scripts').exists(): ROOT = pathlib.Path.cwd()
OK=[]; WARN=[]; FAIL=[]

def add(bucket, name, detail=""):
    bucket.append((name, detail))

def check_file(path, executable=False):
    p=ROOT/path
    if p.exists():
        add(OK, f"file {path}")
        if executable and os.name != 'nt' and not os.access(p, os.X_OK): add(WARN, f"not executable {path}")
    else: add(FAIL, f"missing {path}")

def run(cmd, timeout=15):
    try:
        p=subprocess.run(cmd, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=timeout)
        return p.returncode, p.stdout, p.stderr
    except Exception as e:
        return 999, "", str(e)

def check_bash(path):
    if not shutil.which('bash'):
        add(WARN, 'bash not available', 'skip bash -n')
        return
    code,out,err=run(['bash','-n',str(ROOT/path)])
    (add(OK, f"bash syntax {path}") if code==0 else add(FAIL, f"bash syntax {path}", err[:300]))

def check_py(path):
    try:
        py_compile.compile(str(ROOT/path), doraise=True)
        add(OK, f"python syntax {path}")
    except Exception as e: add(FAIL, f"python syntax {path}", str(e)[:300])

def check_web():
    sys.path.insert(0, str(ROOT/'web'))
    try:
        import app as webapp
        c=webapp.app.test_client()
        for url in ['/', '/cyber', '/ai', '/local-ai', '/api/status']:
            r=c.get(url)
            if r.status_code==200: add(OK, f"web route {url}")
            else: add(FAIL, f"web route {url}", str(r.status_code))
    except Exception as e: add(FAIL, 'web import/routes', repr(e))

def check_routes():
    s=(ROOT/'scripts'/'avid.sh').read_text(errors='ignore') if (ROOT/'scripts'/'avid.sh').exists() else ''
    for word in ['web_start_bg','app_open','run_tool','cyber_essential','local_install_llama','agent_menu','main_menu']:
        if word in s: add(OK, f"avid route/function {word}")
        else: add(FAIL, f"missing avid route/function {word}")

def check_packaging():
    for f in ['avid.ps1','avid.cmd','scripts/avid_pc.py','scripts/avid_desktop.py','packaging/windows/build_exe.ps1','android/build.gradle','android/app/build.gradle','.github/workflows/build-release.yml']:
        check_file(pathlib.Path(f))

def main():
    required=['install.sh','uninstall.sh','scripts/avid.sh','scripts/launcher.sh','scripts/avid_tui.py','scripts/avid_pc.py','web/app.py','agent/avid_agent.py','config.example']
    for f in required: check_file(pathlib.Path(f))
    for f in ['install.sh','uninstall.sh','scripts/avid.sh','scripts/launcher.sh']: check_bash(pathlib.Path(f))
    for f in ['scripts/avid_tui.py','scripts/avid_pc.py','scripts/avid_desktop.py','web/app.py','agent/avid_agent.py','tools/qa_selftest.py']: 
        if (ROOT/f).exists(): check_py(pathlib.Path(f))
    check_routes(); check_web(); check_packaging()
    print('\nAvidKiya DevHub Doctor')
    print('='*34)
    for icon,bucket in [('✅',OK),('⚠️',WARN),('❌',FAIL)]:
        if bucket:
            print(f"\n{icon} {len(bucket)}")
            for name,detail in bucket[:80]: print(f" {icon} {name}" + (f" — {detail}" if detail else ""))
    report={'ok':len(OK),'warn':len(WARN),'fail':len(FAIL)}
    print('\nSummary:', json.dumps(report, ensure_ascii=False))
    return 1 if FAIL else 0
if __name__=='__main__': raise SystemExit(main())
