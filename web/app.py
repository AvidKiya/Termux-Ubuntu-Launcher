#!/usr/bin/env python3
"""Avid Kiya DevHub Web Panel v3.4
Mobile-first, fast cached status, background tasks, bilingual UI.
Runs on localhost only by default.
"""
import os, subprocess, pathlib, datetime, json, shlex, time, uuid
from flask import Flask, render_template, request, redirect, url_for, jsonify, make_response

APP_DIR = pathlib.Path(os.environ.get('AK_APP_DIR', str(pathlib.Path.home()/'.termux-avid-kiya')))
CONFIG = APP_DIR/'config'
LOG_DIR = APP_DIR/'logs'
TASK_DIR = APP_DIR/'tasks'
CACHE = APP_DIR/'web-status.json'
LOG_DIR.mkdir(parents=True, exist_ok=True)
TASK_DIR.mkdir(parents=True, exist_ok=True)
HOST = os.environ.get('AK_WEB_HOST','127.0.0.1')
PORT = int(os.environ.get('AK_WEB_PORT','8765'))
app = Flask(__name__)

I18N = {
 'fa': {'dir':'rtl','title':'Avid Kiya DevHub','subtitle':'مرکز کنترل ترموکس، اوبونتو، هوش مصنوعی، توسعه و امنیت','dashboard':'داشبورد','ai':'هوش مصنوعی','cyber':'امنیت','dev':'توسعه','ubuntu':'اوبونتو','settings':'تنظیمات','logs':'لاگ‌ها','tasks':'تسک‌ها','ok':'آماده','missing':'نیست','checking':'درحال بررسی','install':'نصب / تعمیر','run':'اجرا','quick':'میانبرها','status':'وضعیت','ethics':'فقط برای CTF، لَب دانشگاهی، سیستم‌های شخصی و تست دارای مجوز.','note':'برای ابزارهای تعاملی مثل MiMo و Claude از ترمینال avid استفاده کن. پنل وب برای نصب، تعمیر، وضعیت و لاگ‌هاست.','started':'تسک شروع شد. خروجی را در لاگ‌ها ببین.'},
 'en': {'dir':'ltr','title':'Avid Kiya DevHub','subtitle':'Control center for Termux, Ubuntu, AI, Dev and Cybersecurity','dashboard':'Dashboard','ai':'AI','cyber':'Security','dev':'Dev','ubuntu':'Ubuntu','settings':'Settings','logs':'Logs','tasks':'Tasks','ok':'OK','missing':'Missing','checking':'Checking','install':'Install / Repair','run':'Run','quick':'Quick actions','status':'Status','ethics':'Use only for CTF, university labs, personal systems, and authorized testing.','note':'For interactive tools like MiMo and Claude use the avid terminal menu. Web panel is for install, repair, status and logs.','started':'Task started. Check logs.'}
}

ACTIONS={
 'ubuntu_patch': {'cmd':'avid ubuntu-patch','title':'Ubuntu Patch / Repair'},
 'ai_mimo': {'cmd':'avid ai-mimo','title':'Install MiMo Code'},
 'ai_claude': {'cmd':'avid ai-claude','title':'Install Claude Code'},
 'ai_gemini': {'cmd':'avid ai-gemini','title':'Install Gemini CLI'},
 'ai_aider': {'cmd':'avid ai-aider','title':'Install Aider'},
 'ai_all': {'cmd':'avid ai-all','title':'Install AI Full Pack'},
 'dev_all': {'cmd':'avid dev-all','title':'Install Dev Full Pack'},
 'cyber_essential': {'cmd':'avid cyber-essential','title':'Security Essential Pack'},
 'cyber_recon': {'cmd':'avid cyber-recon','title':'Recon Pack'},
 'cyber_web': {'cmd':'avid cyber-web','title':'Web Security Pack'},
 'cyber_hash': {'cmd':'avid cyber-hash','title':'Hash Auditing Pack'},
 'cyber_ctf': {'cmd':'avid cyber-ctf','title':'CTF / Pwn Pack'},
 'cyber_forensics': {'cmd':'avid cyber-forensics','title':'Forensics Pack'},
 'cyber_reverse': {'cmd':'avid cyber-reverse','title':'Reverse Engineering Pack'},
 'cyber_full': {'cmd':'avid cyber-full','title':'Cybersecurity Full Pack'},
 'health': {'cmd':'avid health-once','title':'Health Check'},
}

def lang():
    l=request.args.get('lang') or request.cookies.get('ak_lang') or os.environ.get('AK_LANGUAGE','fa')
    return l if l in I18N else 'fa'

def run(cmd, timeout=2):
    try:
        p=subprocess.run(cmd, shell=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, timeout=timeout)
        return p.returncode==0, p.stdout.strip()
    except subprocess.TimeoutExpired:
        return False, ''

def exists(cmd): return run(f'command -v {shlex.quote(cmd)} >/dev/null 2>&1', 1)[0]

def ubuntu_exists(): return run('proot-distro login ubuntu -- /bin/true >/dev/null 2>&1', 3)[0]

def ubuntu(cmd, timeout=3): return run(f'proot-distro login ubuntu -- bash -lc {shlex.quote(cmd)} >/dev/null 2>&1', timeout)[0]

def compute_status():
    u=ubuntu_exists()
    s={'Termux': exists('pkg'), 'Ubuntu': u, 'Fish': exists('fish'), 'Web': True}
    if u:
        checks={'MiMo':'command -v mimo >/dev/null 2>&1 || [ -x /root/.mimocode/bin/mimo ]','Claude':'command -v claude >/dev/null 2>&1','Gemini':'command -v gemini >/dev/null 2>&1','Aider':'command -v aider >/dev/null 2>&1','nmap':'command -v nmap >/dev/null 2>&1','sqlmap':'command -v sqlmap >/dev/null 2>&1','john':'command -v john >/dev/null 2>&1','radare2':'command -v radare2 >/dev/null 2>&1','binwalk':'command -v binwalk >/dev/null 2>&1'}
        for k,c in checks.items(): s[k]=ubuntu(c,2)
    else:
        for k in ['MiMo','Claude','Gemini','Aider','nmap','sqlmap','john','radare2','binwalk']: s[k]=False
    data={'time':time.time(),'status':s}
    CACHE.write_text(json.dumps(data), encoding='utf-8')
    return data

def cached_status(max_age=120):
    if CACHE.exists():
        try:
            data=json.loads(CACHE.read_text())
            if time.time()-data.get('time',0) < max_age: return data
        except Exception: pass
    # Return a very fast optimistic shell-only status first if no cache.
    data={'time':0,'status':{'Termux':exists('pkg'),'Ubuntu':False,'Fish':exists('fish'),'Web':True,'MiMo':False,'Claude':False,'Gemini':False,'Aider':False,'nmap':False,'sqlmap':False,'john':False,'radare2':False,'binwalk':False}}
    return data

def start_task(name):
    meta=ACTIONS.get(name)
    if not meta: return None
    tid=datetime.datetime.now().strftime('%Y%m%d-%H%M%S')+'-'+uuid.uuid4().hex[:6]
    log=LOG_DIR/f'task-{name}-{tid}.log'
    task=TASK_DIR/f'{tid}.json'
    cmd=meta['cmd']
    task.write_text(json.dumps({'id':tid,'name':name,'title':meta['title'],'cmd':cmd,'log':log.name,'status':'running','started':time.time()}), encoding='utf-8')
    shell=f'''echo "$ {cmd}"; echo "Started: $(date)"; echo; {cmd}; code=$?; echo; echo "Finished: $(date) code=$code"; python - <<'PY'
import json, pathlib, time
p=pathlib.Path({str(task)!r})
d=json.loads(p.read_text()); d['status']='done'; d['finished']=time.time(); p.write_text(json.dumps(d))
PY
'''
    subprocess.Popen(shell, shell=True, stdout=open(log,'a'), stderr=subprocess.STDOUT, cwd=str(APP_DIR))
    return log.name

def task_list():
    items=[]
    for p in sorted(TASK_DIR.glob('*.json'), key=lambda x:x.stat().st_mtime, reverse=True)[:30]:
        try: items.append(json.loads(p.read_text()))
        except Exception: pass
    return items

@app.route('/')
def index():
    l=lang(); data=cached_status(); resp=make_response(render_template('dashboard.html', t=I18N[l], lang=l, s=data['status'], age=int(time.time()-data.get('time',0)) if data.get('time') else None, page='dashboard'))
    resp.set_cookie('ak_lang', l, max_age=60*60*24*365)
    return resp
@app.route('/ai')
def ai(): l=lang(); return render_template('ai.html', t=I18N[l], lang=l, s=cached_status()['status'], page='ai')
@app.route('/cyber')
def cyber(): l=lang(); return render_template('cyber.html', t=I18N[l], lang=l, s=cached_status()['status'], page='cyber')
@app.route('/dev')
def dev(): l=lang(); return render_template('dev.html', t=I18N[l], lang=l, s=cached_status()['status'], page='dev')
@app.route('/ubuntu')
def ubuntu_page(): l=lang(); return render_template('ubuntu.html', t=I18N[l], lang=l, s=cached_status()['status'], page='ubuntu')
@app.route('/tasks')
def tasks(): l=lang(); return render_template('tasks.html', t=I18N[l], lang=l, tasks=task_list(), page='tasks')
@app.route('/settings', methods=['GET','POST'])
def settings():
    if request.method=='POST':
        old=CONFIG.read_text(errors='ignore') if CONFIG.exists() else ''
        if CONFIG.exists(): CONFIG.with_suffix('.web-backup-'+datetime.datetime.now().strftime('%Y%m%d%H%M%S')).write_text(old)
        keys=['AK_WTTR_LOCATION','AK_WEB_HOST','AK_WEB_PORT','AK_LANGUAGE','AK_USE_LOLCAT','AK_AUTO_FISH_AFTER_TERMUX','AK_AUTO_FISH_AFTER_UBUNTU']
        data={k:request.form.get(k,'') for k in keys}
        lines=[line for line in old.splitlines() if not any(line.startswith(k+'=') for k in keys)]
        for k,v in data.items():
            if v!='': lines.append(f'{k}="{v}"')
        CONFIG.write_text('\n'.join(lines)+'\n')
        return redirect(url_for('settings', saved='1'))
    l=lang(); cfg=CONFIG.read_text(errors='ignore') if CONFIG.exists() else ''
    return render_template('settings.html', t=I18N[l], lang=l, cfg=cfg, page='settings')
@app.route('/logs')
def logs():
    l=lang(); files=sorted(LOG_DIR.glob('*.log'), key=lambda p:p.stat().st_mtime, reverse=True)[:80]
    content=''; name=request.args.get('file')
    if name and (LOG_DIR/name).exists(): content=(LOG_DIR/name).read_text(errors='ignore')[-60000:]
    return render_template('logs.html', t=I18N[l], lang=l, files=files, content=content, page='logs')
@app.route('/action/<name>', methods=['POST'])
def action(name):
    log=start_task(name)
    return redirect(url_for('logs', file=log or 'web.log'))
@app.route('/api/status')
def api_status():
    refresh=request.args.get('refresh')=='1'
    data=compute_status() if refresh else cached_status()
    return jsonify(data)
@app.route('/api/tasks')
def api_tasks(): return jsonify(task_list())

if __name__=='__main__':
    print(f'Avid Kiya DevHub Web Panel: http://{HOST}:{PORT}')
    app.run(host=HOST, port=PORT, threaded=True)
